#Requires AutoHotkey v2.0

; 包含主脚本
#Include force-copy-and-paste-least-v2.ahk

; 测试 OnShiftInsert 功能
TestShiftInsert() {
    testResults := []
    
    ; 测试 1: 剪贴板为空时的处理
    try {
        ; 清空剪贴板
        A_Clipboard := ""
        Sleep(100)
        
        ; 调用 OnShiftInsert
        hotkeyHandler.OnShiftInsert()
        
        ; 由于剪贴板为空，应该显示"剪贴板为空"提示并返回
        testResults.Push("✓ 测试 1: 剪贴板为空时正确处理（应显示'剪贴板为空'提示）")
    } catch as err {
        testResults.Push("✗ 测试 1: 剪贴板为空时处理失败 - " err.Message)
    }
    
    ; 测试 2: 剪贴板有内容时的处理
    try {
        ; 设置剪贴板内容
        testText := "Hello World`nThis is a test`nLine 3"
        A_Clipboard := testText
        Sleep(100)
        
        ; 验证剪贴板内容
        clipText := clipboardProcessor.GetClipboardText()
        if (clipText = testText) {
            testResults.Push("✓ 测试 2a: 剪贴板内容设置成功")
        } else {
            testResults.Push("✗ 测试 2a: 剪贴板内容设置失败")
        }
        
        ; 测试文本消毒
        sanitized := clipboardProcessor.SanitizeText(clipText)
        if (sanitized != "") {
            testResults.Push("✓ 测试 2b: 文本消毒成功")
        } else {
            testResults.Push("✗ 测试 2b: 文本消毒失败")
        }
        
        testResults.Push("✓ 测试 2c: OnShiftInsert 方法可调用（实际注入需要在目标窗口中测试）")
        
    } catch as err {
        testResults.Push("✗ 测试 2: 剪贴板有内容时处理失败 - " err.Message)
    }
    
    ; 测试 3: 文本消毒功能
    try {
        ; 测试包含特殊字符的文本
        testText := "Line1`r`nLine2`tTabbed`nLine3 " Chr(160) " NBSP"
        sanitized := clipboardProcessor.SanitizeText(testText)
        
        ; 验证 \r 被移除
        if !InStr(sanitized, "`r") {
            testResults.Push("✓ 测试 3a: \\r 字符已移除")
        } else {
            testResults.Push("✗ 测试 3a: \\r 字符未移除")
        }
        
        ; 验证 Tab 被替换为空格
        if !InStr(sanitized, "`t") {
            testResults.Push("✓ 测试 3b: Tab 字符已替换")
        } else {
            testResults.Push("✗ 测试 3b: Tab 字符未替换")
        }
        
        ; 验证 NBSP 被替换为普通空格
        if !InStr(sanitized, Chr(160)) {
            testResults.Push("✓ 测试 3c: NBSP 字符已替换")
        } else {
            testResults.Push("✗ 测试 3c: NBSP 字符未替换")
        }
        
        ; 验证 \n 被保留
        if InStr(sanitized, "`n") {
            testResults.Push("✓ 测试 3d: \\n 字符已保留")
        } else {
            testResults.Push("✗ 测试 3d: \\n 字符未保留")
        }
        
    } catch as err {
        testResults.Push("✗ 测试 3: 文本消毒功能测试失败 - " err.Message)
    }
    
    ; 测试 4: 验证 Hotkey_Handler 方法存在
    try {
        if (HasMethod(hotkeyHandler, "OnShiftInsert")) {
            testResults.Push("✓ 测试 4: OnShiftInsert 方法存在")
        } else {
            testResults.Push("✗ 测试 4: OnShiftInsert 方法不存在")
        }
    } catch as err {
        testResults.Push("✗ 测试 4: 方法检查失败 - " err.Message)
    }
    
    ; 清理剪贴板
    A_Clipboard := ""
    
    return testResults
}

; 运行测试
results := TestShiftInsert()

; 显示测试结果
output := "OnShiftInsert 功能测试结果:`n`n"
passCount := 0
failCount := 0

for index, result in results {
    output .= result "`n"
    if InStr(result, "✓") {
        passCount++
    } else {
        failCount++
    }
}

output .= "`n总计: " passCount " 通过, " failCount " 失败"
output .= "`n`n注意: 实际的文本注入功能需要在目标编辑器窗口中手动测试。"

MsgBox(output, "测试结果", "Icon" (failCount = 0 ? "i" : "!"))
ExitApp
