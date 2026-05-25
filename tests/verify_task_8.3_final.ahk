#Requires AutoHotkey v2.0
#SingleInstance Force

; 最终验证脚本 - Task 8.3
; 验证 ShowSettingsWindow() 方法的完整实现

MsgBox("Task 8.3 验证脚本`n`n将验证以下内容：`n• ShowSettingsWindow() 方法存在`n• 所有必需的 GUI 组件`n• 交互逻辑方法", "开始验证", "Iconi")

; 读取主脚本内容
scriptContent := FileRead("force-copy-and-paste-least-v2.ahk")

; 验证结果数组
verificationResults := []

; ============================================================================
; 1. 验证 ShowSettingsWindow 方法存在
; ============================================================================
if (InStr(scriptContent, "ShowSettingsWindow()")) {
    verificationResults.Push("✅ ShowSettingsWindow() 方法已实现")
} else {
    verificationResults.Push("❌ ShowSettingsWindow() 方法未找到")
}

; ============================================================================
; 2. 验证 GUI 组件
; ============================================================================

; 2.1 延迟模式下拉菜单
if (InStr(scriptContent, '延迟模式：') && InStr(scriptContent, 'DropDownList') && InStr(scriptContent, '["Fast", "Standard", "Conservative"]')) {
    verificationResults.Push("✅ 延迟模式下拉菜单已实现")
} else {
    verificationResults.Push("❌ 延迟模式下拉菜单未找到")
}

; 2.2 基础延迟输入框
if (InStr(scriptContent, '基础延迟') && InStr(scriptContent, 'baseDelayEdit') && InStr(scriptContent, '毫秒 (ms)')) {
    verificationResults.Push("✅ 基础延迟输入框已实现")
} else {
    verificationResults.Push("❌ 基础延迟输入框未找到")
}

; 2.3 波动范围输入框
if (InStr(scriptContent, '波动范围') && InStr(scriptContent, 'varianceEdit')) {
    verificationResults.Push("✅ 波动范围输入框已实现")
} else {
    verificationResults.Push("❌ 波动范围输入框未找到")
}

; 2.4 开机自启动复选框
if (InStr(scriptContent, '开机自启动') && InStr(scriptContent, 'startupCheckbox') && InStr(scriptContent, 'actualStartupState')) {
    verificationResults.Push("✅ 开机自启动复选框已实现（读取实际注册表状态）")
} else {
    verificationResults.Push("❌ 开机自启动复选框未找到")
}

; 2.5 管理员权限部分
if (InStr(scriptContent, '管理员权限：') && InStr(scriptContent, '请求管理员权限') && InStr(scriptContent, '当前状态：')) {
    verificationResults.Push("✅ 管理员权限部分已实现")
} else {
    verificationResults.Push("❌ 管理员权限部分未找到")
}

; 2.6 保存和取消按钮
if (InStr(scriptContent, '"保存"') && InStr(scriptContent, '"取消"') && InStr(scriptContent, 'saveBtn') && InStr(scriptContent, 'cancelBtn')) {
    verificationResults.Push("✅ 保存和取消按钮已实现")
} else {
    verificationResults.Push("❌ 保存和取消按钮未找到")
}

; ============================================================================
; 3. 验证交互逻辑方法
; ============================================================================

; 3.1 OnDelayModeChange
if (InStr(scriptContent, "OnDelayModeChange(dropdown, baseDelayEdit, varianceEdit)")) {
    verificationResults.Push("✅ OnDelayModeChange() 方法已实现")
} else {
    verificationResults.Push("❌ OnDelayModeChange() 方法未找到")
}

; 3.2 OnRequestAdminClick
if (InStr(scriptContent, "OnRequestAdminClick()")) {
    verificationResults.Push("✅ OnRequestAdminClick() 方法已实现")
} else {
    verificationResults.Push("❌ OnRequestAdminClick() 方法未找到")
}

; 3.3 OnSaveSettingsClick
if (InStr(scriptContent, "OnSaveSettingsClick(settingsGui, delayModeDropdown, baseDelayEdit, varianceEdit, startupCheckbox)")) {
    verificationResults.Push("✅ OnSaveSettingsClick() 方法已实现")
} else {
    verificationResults.Push("❌ OnSaveSettingsClick() 方法未找到")
}

; 3.4 ValidateInput
if (InStr(scriptContent, "ValidateInput(baseDelay, variance)")) {
    verificationResults.Push("✅ ValidateInput() 方法已实现")
} else {
    verificationResults.Push("❌ ValidateInput() 方法未找到")
}

; ============================================================================
; 4. 验证关键逻辑
; ============================================================================

; 4.1 延迟模式切换事件绑定
if (InStr(scriptContent, 'delayModeDropdown.OnEvent("Change"')) {
    verificationResults.Push("✅ 延迟模式切换事件已绑定")
} else {
    verificationResults.Push("❌ 延迟模式切换事件未绑定")
}

; 4.2 输入验证范围
if (InStr(scriptContent, "baseDelay < 1 || baseDelay > 1000") && InStr(scriptContent, "variance < 0 || variance > 500")) {
    verificationResults.Push("✅ 输入验证范围正确（1-1000ms, 0-500ms）")
} else {
    verificationResults.Push("❌ 输入验证范围不正确")
}

; 4.3 开机自启动智能处理
if (InStr(scriptContent, "currentStartupState := this.startupManager.IsStartupEnabled()") && 
    InStr(scriptContent, "if (startupEnabled && !currentStartupState)") &&
    InStr(scriptContent, "else if (!startupEnabled && currentStartupState)")) {
    verificationResults.Push("✅ 开机自启动智能处理已实现（只在状态改变时修改注册表）")
} else {
    verificationResults.Push("❌ 开机自启动智能处理未找到")
}

; 4.4 保存成功后更新托盘提示
if (InStr(scriptContent, "trayController.UpdateTrayTooltip()")) {
    verificationResults.Push("✅ 保存成功后更新托盘提示")
} else {
    verificationResults.Push("❌ 保存成功后未更新托盘提示")
}

; ============================================================================
; 显示验证结果
; ============================================================================

resultText := "Task 8.3 验证结果`n`n"
resultText .= "=" . StrRepeat("=", 50) . "`n`n"

passCount := 0
failCount := 0

for index, result in verificationResults {
    resultText .= result . "`n"
    if (InStr(result, "✅")) {
        passCount++
    } else {
        failCount++
    }
}

resultText .= "`n" . StrRepeat("=", 50) . "`n"
resultText .= "通过: " passCount . " / " verificationResults.Length . "`n"
resultText .= "失败: " failCount . " / " verificationResults.Length . "`n"

if (failCount = 0) {
    resultText .= "`n🎉 所有验证项通过！Task 8.3 已完成！"
    MsgBox(resultText, "验证成功", "Iconi")
} else {
    resultText .= "`n⚠️ 部分验证项未通过，请检查实现。"
    MsgBox(resultText, "验证失败", "Icon!")
}

; 辅助函数：重复字符串
StrRepeat(str, count) {
    result := ""
    Loop count {
        result .= str
    }
    return result
}
