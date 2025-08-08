@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Edge 自动关闭程序

:: 检查是否有命令行参数
if "%~1" NEQ "" (
    set "INPUT=%~1"
    echo [网页调用] 接收到参数: !INPUT!
    goto PROCESS_INPUT
)

:INPUT_TIME
cls
echo ================================
echo     Edge 自动关闭程序
echo ================================
echo.
echo 请输入关闭时间或倒计时：
echo   - 输入数字 (如 1): 1小时后关闭
echo   - 
echo   - 输入数字s (如 10s): 10秒后关闭 (用于测试)
echo   - 输入时间 (如 22:24): 在 22:24 关闭
echo   - 输入时间 (如 2224): 在 22:24 关闭
echo   - 输入时间 (如 224): 在 02:24 关闭
echo.
set /p INPUT=请输入选项: 

:PROCESS_INPUT
:: 清理输入
set "INPUT=!INPUT: =!"
if "!INPUT!"=="" goto INPUT_TIME

:: 检查是否为秒数输入 (10s)
set "LAST_CHAR=!INPUT:~-1!"
if "!LAST_CHAR!"=="s" (
    set "SECONDS=!INPUT:~0,-1!"
    :: 验证是否为数字
    set /a "TEST=!SECONDS!" 2>nul
    if !TEST! GTR 0 (
        :: 获取当前时间
        for /f "tokens=1-3 delims=:." %%a in ("!TIME!") do (
            set /a "HOUR=%%a" 2>nul
            set /a "MINUTE=%%b" 2>nul
            set /a "SECOND=%%c" 2>nul
        )
        
        :: 计算目标时间
        set /a "TOTAL_SECONDS = HOUR*3600 + MINUTE*60 + SECOND + SECONDS"
        set /a "HOURS = TOTAL_SECONDS / 3600"
        set /a "TEMP = TOTAL_SECONDS - HOURS*3600"
        set /a "MINUTES = TEMP / 60"
        
        :: 处理超过24小时的情况
        if !HOURS! GEQ 24 set /a "HOURS = HOURS - 24"
        
        :: 格式化时间 - 确保两位数
        set "HOURS=0!HOURS!"
        set "HOURS=!HOURS:~-2!"
        set "MINUTES=0!MINUTES!"
        set "MINUTES=!MINUTES:~-2!"
        
        set "CLOSE_TIME=!HOURS!:!MINUTES!"
        goto START_MONITORING
    )
)

:: 检查时间格式 (22:24)
echo !INPUT! | find ":" >nul
if not errorlevel 1 (
    for /f "tokens=1,2 delims=:" %%a in ("!INPUT!") do (
        set /a "HOUR=%%a" 2>nul
        set /a "MINUTE=%%b" 2>nul
    )
    
    :: 验证时间范围
    if !HOUR! GEQ 0 if !HOUR! LEQ 23 if !MINUTE! GEQ 0 if !MINUTE! LEQ 59 (
        :: 格式化时间 - 确保两位数
        set "HOUR=0!HOUR!"
        set "HOUR=!HOUR:~-2!"
        set "MINUTE=0!MINUTE!"
        set "MINUTE=!MINUTE:~-2!"
        
        set "CLOSE_TIME=!HOUR!:!MINUTE!"
        goto START_MONITORING
    )
)

:: 检查是否为纯数字
set "IS_NUMBER=1"
for /f "delims=0123456789" %%i in ("!INPUT!") do set "IS_NUMBER=0"

if !IS_NUMBER!==1 (
    :: 获取输入长度
    set "INPUT_LEN=0"
    set "TEMP=!INPUT!"
    :COUNT_LOOP
    if defined TEMP (
        set "TEMP=!TEMP:~1!"
        set /a "INPUT_LEN+=1"
        goto COUNT_LOOP
    )
    
    :: 根据长度处理
    if !INPUT_LEN!==4 (
        :: 4位数字时间 (2224)
        set "HOUR=!INPUT:~0,2!"
        set "MINUTE=!INPUT:~2,2!"
        set /a "HOUR_NUM=!HOUR!" 2>nul
        set /a "MIN_NUM=!MINUTE!" 2>nul
        
        if !HOUR_NUM! GEQ 0 if !HOUR_NUM! LEQ 23 if !MIN_NUM! GEQ 0 if !MIN_NUM! LEQ 59 (
            set "CLOSE_TIME=!HOUR!:!MINUTE!"
            goto START_MONITORING
        )
    ) else if !INPUT_LEN!==3 (
        :: 3位数字时间 (224)
        set "HOUR=0!INPUT:~0,1!"
        set "MINUTE=!INPUT:~1,2!"
        set /a "HOUR_NUM=!HOUR!" 2>nul
        set /a "MIN_NUM=!MINUTE!" 2>nul
        
        if !HOUR_NUM! GEQ 0 if !HOUR_NUM! LEQ 9 if !MIN_NUM! GEQ 0 if !MIN_NUM! LEQ 59 (
            set "CLOSE_TIME=!HOUR!:!MINUTE!"
            goto START_MONITORING
        )
    ) else (
        :: 小时倒计时 (1, 2, 等)
        set /a "HOURS_TO_ADD=!INPUT!" 2>nul
        if !HOURS_TO_ADD! GTR 0 if !HOURS_TO_ADD! LSS 25 (
            :: 获取当前时间
            for /f "tokens=1-2 delims=:." %%a in ("!TIME!") do (
                set /a "HOUR=%%a" 2>nul
                set /a "MINUTE=%%b" 2>nul
            )
            
            :: 计算目标时间
            set /a "TARGET_HOUR = HOUR + HOURS_TO_ADD"
            set /a "TARGET_MINUTE = MINUTE"
            
            :: 处理超过24小时的情况
            if !TARGET_HOUR! GEQ 24 set /a "TARGET_HOUR = TARGET_HOUR - 24"
            
            :: 格式化时间 - 确保两位数
            set "TARGET_HOUR=0!TARGET_HOUR!"
            set "TARGET_HOUR=!TARGET_HOUR:~-2!"
            set "TARGET_MINUTE=0!TARGET_MINUTE!"
            set "TARGET_MINUTE=!TARGET_MINUTE:~-2!"
            
            set "CLOSE_TIME=!TARGET_HOUR!:!TARGET_MINUTE!"
            goto START_MONITORING
        )
    )
)

:INVALID_INPUT
echo.
echo [错误] 输入格式无效，请重新输入。
timeout /t 3 >nul
goto INPUT_TIME

:START_MONITORING
echo.
echo [确认] Edge 将在: !CLOSE_TIME! 关闭
echo.



:LOOP
cls
echo ================================
echo     Edge 自动关闭程序
echo ================================
echo.
echo 预设关闭时间: !CLOSE_TIME!

:: 获取当前时间
for /f "tokens=1-2 delims=:." %%a in ("!TIME!") do (
    set "CURRENT_HOUR=%%a"
    set "CURRENT_MINUTE=%%b"
)

:: 清理前导空格
set "CURRENT_HOUR=!CURRENT_HOUR: =!"
set "CURRENT_MINUTE=!CURRENT_MINUTE: =!"

:: 格式化为两位数 - 使用更可靠的方法
set "CURRENT_HOUR=0!CURRENT_HOUR!"
set "CURRENT_HOUR=!CURRENT_HOUR:~-2!"
set "CURRENT_MINUTE=0!CURRENT_MINUTE!"
set "CURRENT_MINUTE=!CURRENT_MINUTE:~-2!"

echo 当前时间: !CURRENT_HOUR!:!CURRENT_MINUTE!

:: 检查Edge是否运行
tasklist /fi "imagename eq msedge.exe" 2>nul | find /i "msedge.exe" >nul
if errorlevel 1 (
    echo Edge状态: [未运行]
    set "EDGE_RUNNING=0"
) else (
    echo Edge状态: [正在运行]
    set "EDGE_RUNNING=1"
)
echo.

:: 判断是否到达关闭时间
if "!CURRENT_HOUR!:!CURRENT_MINUTE!"=="!CLOSE_TIME!" (
    echo [通知] 已到达预设关闭时间，正在尝试关闭Edge...
    
    if "!EDGE_RUNNING!"=="0" (
        echo [通知] Edge 未运行，无需关闭。程序将在20秒后自动退出。
        for /l %%i in (20,-1,1) do (
            echo [倒计时] 剩余 %%i 秒...
            timeout /t 1 >nul
        )
        exit
    )
    
    call :CLOSE_EDGE
    
    echo.
    echo [通知] 程序将在20秒后自动退出。
    for /l %%i in (20,-1,1) do (
        echo [倒计时] 剩余 %%i 秒...
        timeout /t 1 >nul
    )
    exit
)

echo [提示] 等待中... 可按 Ctrl+C 终止程序。
timeout /t 30 >nul
goto LOOP

:: ****************************************************
:: 子程序: 关闭Edge进程
:: ****************************************************
:CLOSE_EDGE
echo [尝试] 正在尝试关闭 Edge 进程...

echo   - 尝试使用 taskkill 正常关闭...
taskkill /im msedge.exe >nul 2>&1
timeout /t 3 >nul
tasklist /fi "imagename eq msedge.exe" 2>nul | find /i "msedge.exe" >nul
if errorlevel 1 (echo [成功] Edge 已关闭。 & goto :EOF)

echo   - 尝试使用 taskkill 强制关闭...
taskkill /f /im msedge.exe >nul 2>&1
timeout /t 5 >nul
tasklist /fi "imagename eq msedge.exe" 2>nul | find /i "msedge.exe" >nul
if errorlevel 1 (echo [成功] Edge 已成功关闭。 & goto :EOF)

echo [警告] Edge 无法完全关闭，可能有些进程仍在运行。
goto :EOF