# EdgeAutoClose: Your Microsoft Edge Auto-Close Tool

[English](#english) | [中文](#中文)

## English

EdgeAutoClose is a comprehensive tool designed to help you automatically close Microsoft Edge at a specified time. It combines a web-based graphical user interface (GUI) with a powerful background monitoring script to give you precise control over Edge's runtime.

## Features

*   **Web-based GUI:** An intuitive web interface (`edge_gui.html`) allows you to easily set a specific time or a countdown for Edge to close.
*   **Background Monitoring:** A lightweight Deno server (`edge-stop-server.js`) works in conjunction with a robust batch script (`edge_auto_close.bat`) to continuously monitor and terminate Edge processes at the designated time.
*   **Flexible Time Setting:** Choose from quick presets (e.g., 30 minutes, 1 hour) or set an exact closing time (e.g., 22:30).
*   **Automatic Edge Launch (Optional):** The `edge_auto_close.bat` script can optionally launch Edge if it's not already running when the monitoring begins.
*   **Status Monitoring:** The GUI provides real-time updates on the current time, target close time, countdown, and the status of the background monitoring script.
*   **WebSocket Control:** A WebSocket endpoint (`/ws`) allows for real-time control. Sending the message `stop web` will immediately close all Microsoft Edge processes.

## How to Use

1.  **Start the Server:** Run `start-edge-server.bat`. This batch file will check for Deno, then launch the `edge-stop-server.js` in the background. This server hosts the web GUI and manages the auto-close process.
2.  **Access the GUI:** Open your web browser (preferably not Edge, to avoid conflicts) and navigate to `http://localhost:19100/`. This will load the `edge_gui.html` interface.
3.  **Set Auto-Close Time:** Use the options in the web GUI to set your desired Edge closing time. Once confirmed, the Deno server will launch `edge_auto_close.bat` with the specified time as a parameter.
4.  **Monitor and Close:** The `edge_auto_close.bat` script will run in the background, monitoring the time. When the set time arrives, it will attempt to gracefully close all running Edge processes, and if necessary, forcefully terminate them.
5.  **Manual Close (Optional):** You can also directly run `edge_auto_close.bat` at any time. If run without parameters, it will prompt you to enter a time manually. If run with a time parameter (e.g., `edge_auto_close.bat 22:30`), it will immediately start monitoring for that time.

## Project Files

*   `start-edge-server.bat`: The primary script to initiate the EdgeAutoClose system. It ensures Deno is available and starts the `edge-stop-server.js` in the background.
*   `stop-edge-src/`: This directory contains the core source files for EdgeGuard.
    *   `edge-stop-server.js`: The Deno-based HTTP server. It serves the web GUI, receives time-setting requests, launches `edge_auto_close.bat` with parameters, and provides status updates.
    *   `edge_gui.html`: The interactive web-based graphical user interface. Users interact with this page to set auto-close times and view monitoring status.
    *   `edge_auto_close.bat`: The robust batch script responsible for the actual time monitoring and closing of Microsoft Edge processes. It can be launched by the Deno server or run independently.

## Configuration

The server port can be configured in the `stop-edge-src/.env` file.

---

## 中文

# EdgeAutoClose：你的 Microsoft Edge 自动关闭工具

EdgeAutoClose 是一个全面的工具，旨在帮助你按指定时间自动关闭 Microsoft Edge 浏览器。它结合了基于网页的图形用户界面（GUI）和强大的后台监控脚本，让你精确控制 Edge 的运行时间。

## 功能

*   **基于网页的 GUI：** 直观的网页界面（`edge_gui.html`）让你轻松设置 Edge 的关闭时间或倒计时。
*   **后台监控：** 轻量级的 Deno 服务器（`edge-stop-server.js`）与强大的批处理脚本（`edge_auto_close.bat`）协同工作，持续监控并在指定时间终止 Edge 进程。
*   **灵活的时间设置：** 可以选择快速预设（例如 30 分钟、1 小时），或设置精确的关闭时间（例如 22:30）。
*   **自动启动 Edge（可选）：** `edge_auto_close.bat` 脚本在监控开始时，如果 Edge 未运行，可以选择性地启动它。
*   **状态监控：** GUI 提供当前时间、目标关闭时间、倒计时以及后台监控脚本状态的实时更新。
*   **WebSocket 控制：** 新增的 WebSocket 端点（`/ws`）允许实时控制。发送 `stop web` 消息将立即关闭所有 Microsoft Edge 进程。

## 如何使用

1.  **启动服务器：** 运行 `start-edge-server.bat`。此批处理文件将检查 Deno 是否安装，然后在后台启动 `edge-stop-server.js`。该服务器托管网页 GUI 并管理自动关闭过程。
2.  **访问 GUI：** 打开你的网页浏览器（最好不是 Edge，以避免冲突），并访问 `http://localhost:19100/`。这将加载 `edge_gui.html` 界面。
3.  **设置自动关闭时间：** 使用网页 GUI 中的选项设置你希望 Edge 关闭的时间。确认后，Deno 服务器将启动 `edge_auto_close.bat` 并将指定时间作为参数传递给它。
4.  **监控和关闭：** `edge_auto_close.bat` 脚本将在后台运行，监控时间。当设定的时间到达时，它将尝试正常关闭所有正在运行的 Edge 进程，并在必要时强制终止它们。
5.  **手动关闭（可选）：** 你也可以随时直接运行 `edge_auto_close.bat`。如果无参数运行，它将提示你手动输入时间。如果带时间参数运行（例如 `edge_auto_close.bat 22:30`），它将立即开始监控该时间。

## 项目文件

*   `start-edge-server.bat`：启动 EdgeAutoClose 系统的主脚本。它确保 Deno 可用并在后台启动 `edge-stop-server.js`。
*   `stop-edge-src/`：此目录包含 EdgeGuard 的核心源文件。
    *   `edge-stop-server.js`：基于 Deno 的 HTTP 服务器。它提供网页 GUI，接收时间设置请求，带参数启动 `edge_auto_close.bat`，并提供状态更新。
    *   `edge_gui.html`：交互式网页图形用户界面。用户通过此页面设置自动关闭时间并查看监控状态。
    *   `edge_auto_close.bat`：负责实际时间监控和关闭 Microsoft Edge 进程的强大批处理脚本。它可以由 Deno 服务器启动，也可以独立运行。

## 配置

服务器端口可以在 `stop-edge-src/.env` 文件中进行配置。

---
*Generated by Gemini*