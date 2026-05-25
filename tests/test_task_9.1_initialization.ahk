; ============================================================================
; Task 9.1 Verification Test
; 测试主程序初始化流程
; ============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; 测试结果
testResults := []

; 添加测试结果
AddTestResult(testName, passed, message := "") {
    global testResults
    status := passed ? "✓ PASS" : "✗ FAIL"
    testResults.Push(status " - " testName (message ? ": " message : ""))
}

; ============================================================================
; 测试 1: 验证所有模块实例是否已创建
; ============================================================================

try {
    ; 检查 configManager
    if (IsSet(configManager) && Type(configManager) = "Config_Manager") {
        AddTestResult("Config_Manager 实例创建", true)
    } else {
        AddTestResult("Config_Manager 实例创建", false, "实例不存在或类型错误")
    }
} catch as err {
    AddTestResult("Config_Manager 实例创建", false, err.Message)
}

try {
    ; 检查 delayAlgorithm
    if (IsSet(delayAlgorithm) && Type(delayAlgorithm) = "Delay_Algorithm") {
        AddTestResult("Delay_Algorithm 实例创建", true)
    } else {
        AddTestResult("Delay_Algorithm 实例创建", false, "实例不存在或类型错误")
    }
} catch as err {
    AddTestResult("Delay_Algorithm 实例创建", false, err.Message)
}

try {
    ; 检查 clipboardProcessor
    if (IsSet(clipboardProcessor) && Type(clipboardProcessor) = "Clipboard_Processor") {
        AddTestResult("Clipboard_Processor 实例创建", true)
    } else {
        AddTestResult("Clipboard_Processor 实例创建", false, "实例不存在或类型错误")
    }
} catch as err {
    AddTestResult("Clipboard_Processor 实例创建", false, err.Message)
}

try {
    ; 检查 injectionEngine
    if (IsSet(injectionEngine) && Type(injectionEngine) = "Injection_Engine") {
        AddTestResult("Injection_Engine 实例创建", true)
    } else {
        AddTestResult("Injection_Engine 实例创建", false, "实例不存在或类型错误")
    }
} catch as err {
    AddTestResult("Injection_Engine 实例创建", false, err.Message)
}

try {
    ; 检查 startupManager
    if (IsSet(startupManager) && Type(startupManager) = "Startup_Manager") {
        AddTestResult("Startup_Manager 实例创建", true)
    } else {
        AddTestResult("Startup_Manager 实例创建", false, "实例不存在或类型错误")
    }
} catch as err {
    AddTestResult("Startup_Manager 实例创建", false, err.Message)
}

try {
    ; 检查 uiManager
    if (IsSet(uiManager) && Type(uiManager) = "UI_Manager") {
        AddTestResult("UI_Manager 实例创建", true)
    } else {
        AddTestResult("UI_Manager 实例创建", false, "实例不存在或类型错误")
    }
} catch as err {
    AddTestResult("UI_Manager 实例创建", false, err.Message)
}

try {
    ; 检查 hotkeyHandler
    if (IsSet(hotkeyHandler) && Type(hotkeyHandler) = "Hotkey_Handler") {
        AddTestResult("Hotkey_Handler 实例创建", true)
    } else {
        AddTestResult("Hotkey_Handler 实例创建", false, "实例不存在或类型错误")
    }
} catch as err {
    AddTestResult("Hotkey_Handler 实例创建", false, err.Message)
}

try {
    ; 检查 trayController
    if (IsSet(trayController) && Type(trayController) = "Tray_Controller") {
        AddTestResult("Tray_Controller 实例创建", true)
    } else {
        AddTestResult("Tray_Controller 实例创建", false, "实例不存在或类型错误")
    }
} catch as err {
    AddTestResult("Tray_Controller 实例创建", false, err.Message)
}

; ============================================================================
; 测试 2: 验证依赖关系是否正确
; ============================================================================

try {
    ; 检查 Delay_Algorithm 是否持有 Config_Manager 引用
    if (IsSet(delayAlgorithm.configManager) && Type(delayAlgorithm.configManager) = "Config_Manager") {
        AddTestResult("Delay_Algorithm 依赖 Config_Manager", true)
    } else {
        AddTestResult("Delay_Algorithm 依赖 Config_Manager", false, "依赖未正确设置")
    }
} catch as err {
    AddTestResult("Delay_Algorithm 依赖 Config_Manager", false, err.Message)
}

try {
    ; 检查 Injection_Engine 是否持有 Delay_Algorithm 引用
    if (IsSet(injectionEngine.delayAlgorithm) && Type(injectionEngine.delayAlgorithm) = "Delay_Algorithm") {
        AddTestResult("Injection_Engine 依赖 Delay_Algorithm", true)
    } else {
        AddTestResult("Injection_Engine 依赖 Delay_Algorithm", false, "依赖未正确设置")
    }
} catch as err {
    AddTestResult("Injection_Engine 依赖 Delay_Algorithm", false, err.Message)
}

try {
    ; 检查 UI_Manager 是否持有 Config_Manager 和 Startup_Manager 引用
    hasConfigMgr := IsSet(uiManager.configManager) && Type(uiManager.configManager) = "Config_Manager"
    hasStartupMgr := IsSet(uiManager.startupManager) && Type(uiManager.startupManager) = "Startup_Manager"
    
    if (hasConfigMgr && hasStartupMgr) {
        AddTestResult("UI_Manager 依赖 Config_Manager 和 Startup_Manager", true)
    } else {
        AddTestResult("UI_Manager 依赖 Config_Manager 和 Startup_Manager", false, "依赖未正确设置")
    }
} catch as err {
    AddTestResult("UI_Manager 依赖 Config_Manager 和 Startup_Manager", false, err.Message)
}

try {
    ; 检查 Hotkey_Handler 是否持有 Clipboard_Processor 和 Injection_Engine 引用
    hasClipProc := IsSet(hotkeyHandler.clipboardProcessor) && Type(hotkeyHandler.clipboardProcessor) = "Clipboard_Processor"
    hasInjEngine := IsSet(hotkeyHandler.injectionEngine) && Type(hotkeyHandler.injectionEngine) = "Injection_Engine"
    
    if (hasClipProc && hasInjEngine) {
        AddTestResult("Hotkey_Handler 依赖 Clipboard_Processor 和 Injection_Engine", true)
    } else {
        AddTestResult("Hotkey_Handler 依赖 Clipboard_Processor 和 Injection_Engine", false, "依赖未正确设置")
    }
} catch as err {
    AddTestResult("Hotkey_Handler 依赖 Clipboard_Processor 和 Injection_Engine", false, err.Message)
}

try {
    ; 检查 Tray_Controller 是否持有 UI_Manager 和 Config_Manager 引用
    hasUIMgr := IsSet(trayController.uiManager) && Type(trayController.uiManager) = "UI_Manager"
    hasConfigMgr := IsSet(trayController.configManager) && Type(trayController.configManager) = "Config_Manager"
    
    if (hasUIMgr && hasConfigMgr) {
        AddTestResult("Tray_Controller 依赖 UI_Manager 和 Config_Manager", true)
    } else {
        AddTestResult("Tray_Controller 依赖 UI_Manager 和 Config_Manager", false, "依赖未正确设置")
    }
} catch as err {
    AddTestResult("Tray_Controller 依赖 UI_Manager 和 Config_Manager", false, err.Message)
}

; ============================================================================
; 测试 3: 验证初始化逻辑是否执行
; ============================================================================

try {
    ; 检查配置是否已加载
    if (configManager.delayMode != "" && configManager.baseDelay > 0) {
        AddTestResult("Config_Manager.LoadConfig() 已执行", true)
    } else {
        AddTestResult("Config_Manager.LoadConfig() 已执行", false, "配置未加载")
    }
} catch as err {
    AddTestResult("Config_Manager.LoadConfig() 已执行", false, err.Message)
}

try {
    ; 检查托盘图标是否已创建（通过检查 A_IconHidden）
    if (!A_IconHidden) {
        AddTestResult("Tray_Controller.CreateTrayIcon() 已执行", true)
    } else {
        AddTestResult("Tray_Controller.CreateTrayIcon() 已执行", false, "托盘图标未显示")
    }
} catch as err {
    AddTestResult("Tray_Controller.CreateTrayIcon() 已执行", false, err.Message)
}

; ============================================================================
; 显示测试结果
; ============================================================================

resultText := "Task 9.1 初始化流程验证测试结果`n`n"
resultText .= "=" . StrRepeat("=", 50) . "`n`n"

passCount := 0
failCount := 0

for index, result in testResults {
    resultText .= result . "`n"
    if (InStr(result, "✓ PASS")) {
        passCount++
    } else {
        failCount++
    }
}

resultText .= "`n" . StrRepeat("=", 50) . "`n"
resultText .= "总计: " testResults.Length " 个测试`n"
resultText .= "通过: " passCount " 个`n"
resultText .= "失败: " failCount " 个`n"

if (failCount = 0) {
    resultText .= "`n✓ 所有测试通过！Task 9.1 已完成。"
} else {
    resultText .= "`n✗ 存在失败的测试，请检查。"
}

MsgBox(resultText, "Task 9.1 测试结果", "Iconi")

; 退出测试脚本
ExitApp

; 辅助函数：重复字符串
StrRepeat(str, count) {
    result := ""
    Loop count {
        result .= str
    }
    return result
}
