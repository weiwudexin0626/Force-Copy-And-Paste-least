#Requires AutoHotkey v2.0

; 简单测试脚本，用于验证 Startup_Manager 的功能

; 定义 Startup_Manager 类（从主脚本复制）
class Startup_Manager {
    regKey := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    regValueName := "YouCanCopyAndPasteV2"
    
    __New() {
    }
    
    EnableStartup(scriptPath) {
        try {
            RegWrite(scriptPath, "REG_SZ", this.regKey, this.regValueName)
            return true
        } catch as err {
            MsgBox("启用开机自启动失败: " err.Message, "错误", "Icon!")
            return false
        }
    }
    
    DisableStartup() {
        try {
            RegDelete(this.regKey, this.regValueName)
            return true
        } catch as err {
            if (InStr(err.Message, "找不到") || InStr(err.Message, "not found")) {
                return true
            } else {
                MsgBox("禁用开机自启动失败: " err.Message, "错误", "Icon!")
                return false
            }
        }
    }
    
    IsStartupEnabled() {
        try {
            value := RegRead(this.regKey, this.regValueName)
            return true
        } catch {
            return false
        }
    }
}

; 创建测试实例
startupMgr := Startup_Manager()

; 测试脚本路径
testPath := A_ScriptFullPath

; 测试流程
MsgBox("开始测试 Startup_Manager 功能", "测试", "Iconi")

; 1. 检查初始状态
initialState := startupMgr.IsStartupEnabled()
MsgBox("初始状态: " (initialState ? "已启用" : "未启用"), "测试结果", "Iconi")

; 2. 启用自启动
MsgBox("正在启用自启动...", "测试", "Iconi")
enableResult := startupMgr.EnableStartup(testPath)
if (enableResult) {
    MsgBox("启用成功", "测试结果", "Iconi")
} else {
    MsgBox("启用失败", "测试结果", "Icon!")
}

; 3. 检查启用后的状态
afterEnableState := startupMgr.IsStartupEnabled()
MsgBox("启用后状态: " (afterEnableState ? "已启用" : "未启用"), "测试结果", "Iconi")

; 4. 禁用自启动
MsgBox("正在禁用自启动...", "测试", "Iconi")
disableResult := startupMgr.DisableStartup()
if (disableResult) {
    MsgBox("禁用成功", "测试结果", "Iconi")
} else {
    MsgBox("禁用失败", "测试结果", "Icon!")
}

; 5. 检查禁用后的状态
afterDisableState := startupMgr.IsStartupEnabled()
MsgBox("禁用后状态: " (afterDisableState ? "已启用" : "未启用"), "测试结果", "Iconi")

; 6. 测试总结
summary := "测试完成！`n`n"
summary .= "初始状态: " (initialState ? "已启用" : "未启用") "`n"
summary .= "启用操作: " (enableResult ? "成功" : "失败") "`n"
summary .= "启用后状态: " (afterEnableState ? "已启用" : "未启用") "`n"
summary .= "禁用操作: " (disableResult ? "成功" : "失败") "`n"
summary .= "禁用后状态: " (afterDisableState ? "已启用" : "未启用") "`n`n"

; 验证逻辑
if (enableResult && afterEnableState && disableResult && !afterDisableState) {
    summary .= "✓ 所有测试通过！"
} else {
    summary .= "✗ 部分测试失败，请检查实现"
}

MsgBox(summary, "测试总结", "Iconi")

ExitApp
