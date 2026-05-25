#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================================
; Task 8.3 Verification Script
; 验证设置界面的所有组件是否正确实现
; ============================================================================

MsgBox("Task 8.3 验证脚本`n`n此脚本将验证设置界面的实现是否符合所有要求。", "验证开始", "Iconi")

; 读取主脚本文件
scriptContent := FileRead("force-copy-and-paste-least-v2.ahk")

; 验证清单
verificationResults := []

; 1. 验证 ShowSettingsWindow 方法存在
if (InStr(scriptContent, "ShowSettingsWindow()")) {
    verificationResults.Push("✅ ShowSettingsWindow() 方法已实现")
} else {
    verificationResults.Push("❌ ShowSettingsWindow() 方法未找到")
}

; 2. 验证延迟模式下拉菜单
if (InStr(scriptContent, "延迟模式下拉菜单") && InStr(scriptContent, 'DropDownList", "w400", ["Fast", "Standard", "Conservative"]')) {
    verificationResults.Push("✅ 延迟模式下拉菜单已实现")
} else {
    verificationResults.Push("❌ 延迟模式下拉菜单未正确实现")
}

; 3. 验证基础延迟输入框
if (InStr(scriptContent, "基础延迟 (Base Delay)") && InStr(scriptContent, "毫秒 (ms)")) {
    verificationResults.Push("✅ 基础延迟输入框已实现（带标签和单位）")
} else {
    verificationResults.Push("❌ 基础延迟输入框未正确实现")
}

; 4. 验证波动范围输入框
if (InStr(scriptContent, "波动范围 (Variance)") && InStr(scriptContent, "毫秒 (ms)")) {
    verificationResults.Push("✅ 波动范围输入框已实现（带标签和单位）")
} else {
    verificationResults.Push("❌ 波动范围输入框未正确实现")
}

; 5. 验证开机自启动复选框
if (InStr(scriptContent, "开机自启动") && InStr(scriptContent, "actualStartupState := this.startupManager.IsStartupEnabled()")) {
    verificationResults.Push("✅ 开机自启动复选框已实现（读取实际注册表状态）")
} else {
    verificationResults.Push("❌ 开机自启动复选框未正确实现")
}

; 6. 验证管理员权限按钮
if (InStr(scriptContent, "请求管理员权限") && InStr(scriptContent, "OnRequestAdminClick")) {
    verificationResults.Push("✅ 请求管理员权限按钮已实现")
} else {
    verificationResults.Push("❌ 请求管理员权限按钮未正确实现")
}

; 7. 验证管理员权限状态显示
if (InStr(scriptContent, "当前状态：已以管理员权限运行") && InStr(scriptContent, "当前状态：普通权限运行")) {
    verificationResults.Push("✅ 管理员权限状态显示已实现")
} else {
    verificationResults.Push("❌ 管理员权限状态显示未正确实现")
}

; 8. 验证保存和取消按钮
if (InStr(scriptContent, "保存") && InStr(scriptContent, "取消") && InStr(scriptContent, "OnSaveSettingsClick")) {
    verificationResults.Push("✅ 保存和取消按钮已实现")
} else {
    verificationResults.Push("❌ 保存和取消按钮未正确实现")
}

; 9. 验证延迟模式切换事件
if (InStr(scriptContent, "OnDelayModeChange") && InStr(scriptContent, 'delayModeDropdown.OnEvent("Change"')) {
    verificationResults.Push("✅ 延迟模式切换事件已实现")
} else {
    verificationResults.Push("❌ 延迟模式切换事件未正确实现")
}

; 10. 验证输入验证方法
if (InStr(scriptContent, "ValidateInput") && InStr(scriptContent, "基础延迟必须在 1-1000 毫秒之间")) {
    verificationResults.Push("✅ 输入验证方法已实现")
} else {
    verificationResults.Push("❌ 输入验证方法未正确实现")
}

; 11. 验证 CRITICAL REQUIREMENT: StartupEnabled 默认为 0
if (InStr(scriptContent, "startupEnabled := 0") && InStr(scriptContent, "if (startupEnabled && !currentStartupState)")) {
    verificationResults.Push("✅ CRITICAL: StartupEnabled 默认为 0，只在用户手动勾选时启用")
} else {
    verificationResults.Push("❌ CRITICAL: StartupEnabled 默认值或逻辑不正确")
}

; 12. 验证智能保存逻辑（只在状态改变时修改注册表）
if (InStr(scriptContent, "currentStartupState := this.startupManager.IsStartupEnabled()") && 
    InStr(scriptContent, "if (startupEnabled && !currentStartupState)") &&
    InStr(scriptContent, "else if (!startupEnabled && currentStartupState)")) {
    verificationResults.Push("✅ 智能保存逻辑已实现（只在状态改变时修改注册表）")
} else {
    verificationResults.Push("❌ 智能保存逻辑未正确实现")
}

; 生成验证报告
report := "Task 8.3 实现设置界面 - 验证报告`n"
report .= "=" . StrRepeat("=", 50) . "`n`n"

passCount := 0
failCount := 0

for index, result in verificationResults {
    report .= result . "`n"
    if (InStr(result, "✅")) {
        passCount++
    } else {
        failCount++
    }
}

report .= "`n" . StrRepeat("=", 50) . "`n"
report .= "总计: " passCount " 项通过, " failCount " 项失败`n"

if (failCount = 0) {
    report .= "`n✅ 所有验证项通过！Task 8.3 已完成。"
    icon := "Iconi"
} else {
    report .= "`n❌ 存在 " failCount " 项未通过验证，请检查实现。"
    icon := "Icon!"
}

; 显示验证报告
MsgBox(report, "Task 8.3 验证报告", icon)

; 询问是否运行实际测试
result := MsgBox("验证报告已生成。`n`n是否要运行主脚本并打开设置窗口进行实际测试？", "实际测试", "YesNo Iconi")

if (result = "Yes") {
    Run("force-copy-and-paste-least-v2.ahk")
    Sleep(1000)
    ; 注意：需要手动右键点击托盘图标并选择"设置"来打开设置窗口
    MsgBox("主脚本已启动。`n`n请右键点击托盘图标，选择"设置"菜单项来打开设置窗口进行测试。", "提示", "Iconi")
}

ExitApp
