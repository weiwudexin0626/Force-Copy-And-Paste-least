; ============================================================================
; Task 10.1 Error Handling Verification Test
; 测试全局错误处理功能
; ============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; 测试结果
testResults := []

; ============================================================================
; Test 1: Config_Manager 错误处理测试
; ============================================================================
TestConfigManagerErrorHandling() {
    global testResults
    
    try {
        ; 创建一个临时配置管理器
        testConfigMgr := Config_Manager(A_ScriptDir "\test_temp")
        
        ; 测试 1.1: LoadConfig 在文件不存在时应创建默认配置
        testConfigMgr.LoadConfig()
        if (testConfigMgr.delayMode = "Standard" && testConfigMgr.baseDelay = 30) {
            testResults.Push("✓ Config_Manager.LoadConfig() - 文件不存在时创建默认配置")
        } else {
            testResults.Push("✗ Config_Manager.LoadConfig() - 默认配置创建失败")
        }
        
        ; 测试 1.2: SaveConfig 错误处理
        if (testConfigMgr.SaveConfig()) {
            testResults.Push("✓ Config_Manager.SaveConfig() - 正常保存")
        } else {
            testResults.Push("✗ Config_Manager.SaveConfig() - 保存失败")
        }
        
        ; 清理测试文件
        if FileExist(A_ScriptDir "\test_temp\config.ini") {
            FileDelete(A_ScriptDir "\test_temp\config.ini")
            DirDelete(A_ScriptDir "\test_temp")
        }
        
    } catch as err {
        testResults.Push("✗ Config_Manager 错误处理测试失败: " err.Message)
    }
}

; ============================================================================
; Test 2: Clipboard_Processor 错误处理测试
; ============================================================================
TestClipboardProcessorErrorHandling() {
    global testResults
    
    try {
        clipProc := Clipboard_Processor()
        
        ; 测试 2.1: GetClipboardText 应该能处理空剪贴板
        A_Clipboard := ""
        Sleep(100)
        clipText := clipProc.GetClipboardText()
        if (clipText = "") {
            testResults.Push("✓ Clipboard_Processor.GetClipboardText() - 空剪贴板处理")
        } else {
            testResults.Push("✗ Clipboard_Processor.GetClipboardText() - 空剪贴板处理失败")
        }
        
        ; 测试 2.2: SanitizeText 应该能处理空字符串
        sanitized := clipProc.SanitizeText("")
        if (sanitized = "") {
            testResults.Push("✓ Clipboard_Processor.SanitizeText() - 空字符串处理")
        } else {
            testResults.Push("✗ Clipboard_Processor.SanitizeText() - 空字符串处理失败")
        }
        
        ; 测试 2.3: SanitizeText 应该能处理正常文本
        testText := "Hello`r`nWorld`t!"
        sanitized := clipProc.SanitizeText(testText)
        if (InStr(sanitized, "`r") = 0 && InStr(sanitized, "`t") = 0) {
            testResults.Push("✓ Clipboard_Processor.SanitizeText() - 文本消毒功能")
        } else {
            testResults.Push("✗ Clipboard_Processor.SanitizeText() - 文本消毒失败")
        }
        
    } catch as err {
        testResults.Push("✗ Clipboard_Processor 错误处理测试失败: " err.Message)
    }
}

; ============================================================================
; Test 3: Injection_Engine 错误处理测试
; ============================================================================
TestInjectionEngineErrorHandling() {
    global testResults
    
    try {
        ; 创建必要的依赖
        testConfigMgr := Config_Manager(A_ScriptDir)
        testConfigMgr.LoadConfig()
        testDelayAlgo := Delay_Algorithm(testConfigMgr)
        testInjEngine := Injection_Engine(testDelayAlgo)
        
        ; 测试 3.1: ReleaseModifierKeys 应该能正常执行
        testInjEngine.ReleaseModifierKeys()
        testResults.Push("✓ Injection_Engine.ReleaseModifierKeys() - 正常执行")
        
        ; 测试 3.2: ShowProgress 应该能处理错误
        testInjEngine.ShowProgress(10, 100)
        testResults.Push("✓ Injection_Engine.ShowProgress() - 正常执行")
        
        ; 清除 ToolTip
        ToolTip()
        
    } catch as err {
        testResults.Push("✗ Injection_Engine 错误处理测试失败: " err.Message)
    }
}

; ============================================================================
; Test 4: Delay_Algorithm 错误处理测试
; ============================================================================
TestDelayAlgorithmErrorHandling() {
    global testResults
    
    try {
        ; 创建配置管理器
        testConfigMgr := Config_Manager(A_ScriptDir)
        testConfigMgr.LoadConfig()
        
        ; 创建延迟算法实例
        testDelayAlgo := Delay_Algorithm(testConfigMgr)
        
        ; 测试 4.1: GenerateDelay 应该返回有效值
        delay := testDelayAlgo.GenerateDelay()
        if (delay >= 1 && delay <= 1000) {
            testResults.Push("✓ Delay_Algorithm.GenerateDelay() - 返回有效延迟值: " delay "ms")
        } else {
            testResults.Push("✗ Delay_Algorithm.GenerateDelay() - 返回无效延迟值: " delay "ms")
        }
        
        ; 测试 4.2: GetPresetValues 应该返回正确的预设值
        presetFast := testDelayAlgo.GetPresetValues("Fast")
        if (presetFast.baseDelay = 10 && presetFast.variance = 5) {
            testResults.Push("✓ Delay_Algorithm.GetPresetValues('Fast') - 返回正确预设值")
        } else {
            testResults.Push("✗ Delay_Algorithm.GetPresetValues('Fast') - 预设值错误")
        }
        
    } catch as err {
        testResults.Push("✗ Delay_Algorithm 错误处理测试失败: " err.Message)
    }
}

; ============================================================================
; Test 5: Startup_Manager 错误处理测试
; ============================================================================
TestStartupManagerErrorHandling() {
    global testResults
    
    try {
        testStartupMgr := Startup_Manager()
        
        ; 测试 5.1: IsStartupEnabled 应该能正常执行
        isEnabled := testStartupMgr.IsStartupEnabled()
        testResults.Push("✓ Startup_Manager.IsStartupEnabled() - 正常执行，返回: " (isEnabled ? "已启用" : "未启用"))
        
        ; 测试 5.2: IsAdmin 应该能正常执行
        isAdmin := testStartupMgr.IsAdmin()
        testResults.Push("✓ Startup_Manager.IsAdmin() - 正常执行，返回: " (isAdmin ? "管理员" : "普通用户"))
        
    } catch as err {
        testResults.Push("✗ Startup_Manager 错误处理测试失败: " err.Message)
    }
}

; ============================================================================
; 运行所有测试
; ============================================================================
RunAllTests() {
    global testResults
    
    testResults := []
    
    ; 显示测试开始
    ToolTip("开始测试...")
    Sleep(500)
    
    ; 运行测试
    TestConfigManagerErrorHandling()
    TestClipboardProcessorErrorHandling()
    TestInjectionEngineErrorHandling()
    TestDelayAlgorithmErrorHandling()
    TestStartupManagerErrorHandling()
    
    ; 清除 ToolTip
    ToolTip()
    
    ; 显示测试结果
    resultText := "Task 10.1 错误处理测试结果`n"
    resultText .= "================================`n`n"
    
    passCount := 0
    failCount := 0
    
    for index, result in testResults {
        resultText .= result "`n"
        if (SubStr(result, 1, 1) = "✓") {
            passCount++
        } else {
            failCount++
        }
    }
    
    resultText .= "`n================================`n"
    resultText .= "通过: " passCount " | 失败: " failCount " | 总计: " testResults.Length
    
    ; 显示结果
    MsgBox(resultText, "测试结果", "Iconi T30")
    
    ; 退出测试脚本
    ExitApp
}

; ============================================================================
; 启动测试
; ============================================================================
RunAllTests()
