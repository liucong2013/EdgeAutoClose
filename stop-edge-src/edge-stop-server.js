// server.js
import { serve } from "https://deno.land/std@0.140.0/http/server.ts";
import { config } from "https://deno.land/x/dotenv/mod.ts";

// Load environment variables from .env file
const env = await config({ path: "./.env", defaultsPath: null });
const WEBSOCKET_URL = env.WEBSOCKET_URL || "ws://127.0.0.1:8010/ws"; // Fallback to default

async function handler(req) {
  const url = new URL(req.url);
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
  };

  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders });
  }

  // --- NEW: Config Endpoint ---
  if (url.pathname === "/config") {
      return new Response(JSON.stringify({ websocketUrl: WEBSOCKET_URL }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
  }

  // 1. Serve the HTML GUI
  if (url.pathname === "/") {
    try {
      const htmlContent = await Deno.readTextFile("./edge_gui.html");
      return new Response(htmlContent, { headers: { "Content-Type": "text/html" } });
    } catch (error) {
      console.error("Could not read HTML file:", error);
      return new Response("Could not find HTML file.", { status: 500 });
    }
  }

  // 2. Start the Edge auto-close batch file IN A NEW WINDOW
  if (url.pathname === "/close-edge" && req.method === "POST") {
    console.log("Received request to close Edge...");
    const requestData = await req.json();
    let timeParam;

    if (requestData.hour !== undefined && requestData.minute !== undefined) {
      timeParam = `${String(requestData.hour).padStart(2, '0')}:${String(requestData.minute).padStart(2, '0')}`;
      console.log(`Issuing 'start' command for batch file with time: ${timeParam}`);
    } else {
      return new Response("Invalid request body. Expected 'hour' and 'minute'.", { status: 400 });
    }

    const command = new Deno.Command("cmd.exe", {
      args: ["/c", "start", ".\\edge_auto_close.bat", timeParam],
    });
    
    try {
      const child = command.spawn();
      console.log(`Successfully issued command to launch batch file in a new window.`);
      return new Response("Command to launch batch file issued.", { status: 200 });
    } catch (error) {
      console.error("Failed to issue 'start' command:", error);
      return new Response("Failed to execute 'start' command.", { status: 500 });
    }
  }

  // 3. Close Edge Immediately
  if (url.pathname === "/close-edge-now" && req.method === "POST") {
    console.log("Received request to close Edge immediately...");
    const command = new Deno.Command("taskkill", {
      args: ["/F", "/IM", "msedge.exe"],
    });
    
    try {
      const { code, stdout, stderr } = await command.output();
      if (code === 0) {
        console.log("Successfully sent command to close Edge.");
        return new Response(JSON.stringify({ message: "Close command sent successfully." }), { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } });
      } else {
        // taskkill returns code 128 if the process is not found, which is not a server error.
        const errorMsg = new TextDecoder().decode(stderr);
        console.log(`Command to close Edge finished with code ${code}: ${errorMsg}`);
        return new Response(JSON.stringify({ message: "Edge process not found or could not be closed.", details: errorMsg }), { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } });
      }
    } catch (error) {
      console.error("Failed to execute 'taskkill' command:", error);
      return new Response(JSON.stringify({ message: "Failed to execute taskkill command." }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }
  }

  // 4. Check the status of the batch file
  if (url.pathname === "/status" && req.method === "GET") {
    const psCommand = `if (Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -like '*edge_auto_close.bat*' }) { Write-Output 'true' } else { Write-Output 'false' }`;
    const command = new Deno.Command("powershell.exe", {
        args: ["-Command", psCommand],
        stdout: "piped",
        stderr: "piped",
    });

    try {
      const { code, stdout, stderr } = await command.output();
      const output = new TextDecoder().decode(stdout).trim();
      const errorOutput = new TextDecoder().decode(stderr).trim();

      if (errorOutput && !errorOutput.includes("no instances available")) {
          console.error(`PowerShell stderr: ${errorOutput}`);
      }

      const isRunning = output.toLowerCase() === 'true';
      
      return new Response(JSON.stringify({ isRunning }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error) {
      console.error("Error checking status with PowerShell:", error);
      return new Response(JSON.stringify({ isRunning: false, error: "Server error while checking status." }), { status: 500, headers: { "Content-Type": "application/json" } });
    }
  }

  // 4. Shutdown the server
  if (url.pathname === "/shutdown" && req.method === "POST") {
    console.log("Shutdown request received. Server is shutting down.");
    const response = new Response("Server is shutting down.", { status: 200 });
    setTimeout(() => {
        Deno.exit(0);
    }, 500); // 500ms delay to ensure response is sent
    return response;
  }

  return new Response("Not Found", { status: 404 });
}

console.log("Server running at http://localhost:19100/");
serve(handler, { port: 19100 });