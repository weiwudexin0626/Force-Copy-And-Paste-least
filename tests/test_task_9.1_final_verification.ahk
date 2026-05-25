#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================================
; Task 9.1 Final Verification Test
; 测试主程序初始化流程是否正确
; ============================================================================

; 测试结果
testResults := []
allPassed := true

; 辅助函数：添加测试结果
AddTestResult(testName, passed, message := "") {
    global testResults, allPassed
    status := passed ? "✓ PASS" : "✗ FAIL"
    testResults.Push(status " - " testName (message ? ": " message : ""))
    if (!passed) {
        allPassed := false
    }
}

; ============================================================================
; 测试 1: 验证所有全局实例是否已创建
; ============================================================================

try {
    ; 加载主脚本（通过 #Include 或直接运行）
    ; 由于我们需要测试全局变量，我们将直接检查主脚本文件
    
    ; 读取主脚本内容
    scriptContent := FileRead("force-copy-and-paste-least-v2.ahk")
    
    ; 检查是否包含所有必需的实例创建代码
    requiredInstances := [
        {name: "Config_Manager", pattern: "global configManager := Config_Manager"},
        {name: "Delay_Algorithm", pattern: "global delayAlgorithm := Delay_Algorithm"},
        {name: "Clipboard_Processor", pattern: "global clipboardProcessor := Clipboard_Processor"},
        {name: "Injection_Engine", pattern: "global injectionEngine := Injection_Engine"},
        {name: "Startup_Manager", pattern: "global startupManager := Startup_Manager"},
        {name: "UI_Manager", pattern: "global uiManager := UI_Manager"},
        {name: "Hotkey_Handler", pattern: "global hotkeyHandler := Hotkey_Handler"},
        {name: "Tray_Controller", pattern: "global trayController := Tray_Controller"}
    ]
    
    for instance in requiredInstances {
        if (InStr(scriptContent, instance.pattern)) {
            AddTestResult("实例创建: " instance.name, true)
        } else {
            AddTestResult("实例创建: " instance.name, false, "未找到实例创建代码")
        }
    }
    
} catch as err {
    AddTestResult("读取主脚本文件", false, err.Message)
}

; ============================================================================
; 测试 2: 验证依赖顺序是否正确
; ============================================================================

try {
    ; 检查实例创建的顺序
    ; Config_Manager 应该在 Delay_Algorithm 之前
    configPos := InStr(scriptContent, "global configManager := Config_Manager")
    delayPos := InStr(scriptContent, "global delayAlgorithm := Delay_Algorithm")
    
    if (configPos > 0 && delayPos > 0 && configPos < delayPos) {
        AddTestResult("依赖顺序: Config_Manager -> Delay_Algorithm", true)
    } else {
        AddTestResult("依赖顺序: Config_Manager -> Delay_Algorithm", false, "顺序不正确")
    }
    
    ; Delay_Algorithm 应该在 Injection_Engine 之前
    injectionPos := InStr(scriptContent, "global injectionEngine := Injection_Engine")
    
    if (delayPos > 0 && injectionPos > 0 && delayPos < injectionPos) {
        AddTestResult("依赖顺序: Delay_Algorithm -> Injection_Engine", true)
    } else {
        AddTestResult("依赖顺序: Delay_Algorithm -> Injection_Engine", false, "顺序不正确")
    }
    
    ; Clipboard_Processor 和 Injection_Engine 应该在 Hotkey_Handler 之前
    clipboardPos := InStr(scriptContent, "global clipboardProcessor := Clipboard_Processor")
    hotkeyPos := InStr(scriptContent, "global hotkeyHandler := Hotkey_Handler")
    
    if (clipboardPos > 0 && injectionPos > 0 && hotkeyPos > 0 && clipboardPos < hotkeyPos && injectionPos < hotkeyPos) {
        AddTestResult("依赖顺序: Clipboard_Processor & Injection_Engine -> Hotkey_Handler", true)
    } else {
        AddTestResult("依赖顺序: Clipboard_Processor & Injection_Engine -> Hotkey_Handler", false, "顺序不正确")
    }
    
    ; Config_Manager 和 Startup_Manager 应该在 UI_Manager 之前
    startupPos := InStr(scriptContent, "global startupManager := Startup_Manager")
    uiPos := InStr(scriptContent, "global uiManager := UI_Manager")
    
    if (configPos > 0 && startupPos > 0 && uiPos > 0 && configPos < uiPos && startupPos < uiPos) {
        AddTestResult("依赖顺序: Config_Manager & Startup_Manager -> UI_Manager", true)
    } else {
        AddTestResult("依赖顺序: Config_Manager & Startup_Manager -> UI_Manager", false, "顺序不正确")
    }
    
    ; UI_Manager 和 Config_Manager 应该在 Tray_Controller 之前
    trayPos := InStr(scriptContent, "global trayController := Tray_Controller")
    
    if (uiPos > 0 && configPos > 0 && trayPos > 0 && uiPos < trayPos && configPos < trayPos) {
        AddTestResult("依赖顺序: UI_Manager & Config_Manager -> Tray_Controller", true)
    } else {
        AddTestResult("依赖顺序: UI_Manager & Config_Manager -> Tray_Controller", false, "顺序不正确")
    }
    
} catch as err {
    AddTestResult("验证依赖顺序", false, err.Message)
}

; ============================================================================
; 测试 3: 验证初始化流程是否完整
; ============================================================================

try {
    ; 检查是否包含必要的初始化步骤
    initSteps := [
        {name: "LoadConfig", pattern: "configManager.LoadConfig()"},
        {name: "CreateTrayIcon", pattern: "trayController.CreateTrayIcon()"},
        {name: "UpdateTrayTooltip", pattern: "trayController.UpdateTrayTooltip()"},
        {name: "RegisterHotkeys", pattern: "hotkeyHandler.RegisterHotkeys()"}
    ]
    
    for step in initSteps {
        if (InStr(scriptContent, step.pattern)) {
            AddTestResult("初始化步骤: " step.name, true)
        } else {
            AddTestResult("初始化步骤: " step.name, false, "未找到初始化调用")
        }
    }
    
    ; 检查首次运行检查
    if (InStr(scriptContent, "if (configManager.IsFirstRun())")) {
        AddTestResult("首次运行检查", true)
    } else {
        AddTestResult("首次运行检查", false, "未找到首次运行检查代码")
    }
    
} catch as err {
    AddTestResult("验证初始化流程", false, err.Message)
}

; ============================================================================
; 显示测试结果
; ============================================================================

resultText := "Task 9.1 初始化流程验证结果`n"
resultText .= "================================`n`n"

for result in testResults {
    resultText .= result "`n"
}

resultText .= "`n================================`n"
resultText .= allPassed ? "✓ 所有测试通过！" : "✗ 部分测试失败"

MsgBox(resultText, "Task 9.1 验证结果", allPassed ? "Iconi" : "Icon!")

ExitApp
