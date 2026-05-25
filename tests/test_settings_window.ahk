#Requires AutoHotkey v2.0
#SingleInstance Force

; 测试设置界面功能
; 这个脚本用于验证 Task 8.3 的实现

; ============================================================================
; 简化的 Config_Manager 类（用于测试）
; ============================================================================
class Config_Manager {
    configPath := ""
    delayMode := "Standard"
    baseDelay := 30
    delayVariance := 15
    startupEnabled := 0
    firstRun := 1
    
    __New(scriptDir) {
        this.configPath := scriptDir "\config_test.ini"
    }
    
    LoadConfig() {
        try {
            if !FileExist(this.configPath) {
                this.CreateDefaultConfig()
                return
            }
            
            this.delayMode := IniRead(this.configPath, "Settings", "DelayMode", "Standard")
            this.baseDelay := Integer(IniRead(this.configPath, "Settings", "BaseDelay", "30"))
            this.delayVariance := Integer(IniRead(this.configPath, "Settings", "DelayVariance", "15"))
            this.startupEnabled := Integer(IniRead(this.configPath, "Settings", "StartupEnabled", "0"))
            this.firstRun := Integer(IniRead(this.configPath, "Settings", "FirstRun", "1"))
        } catch {
            this.CreateDefaultConfig()
        }
    }
    
    SaveConfig() {
        try {
            IniWrite(this.delayMode, this.configPath, "Settings", "DelayMode")
            IniWrite(this.baseDelay, this.configPath, "Settings", "BaseDelay")
            IniWrite(this.delayVariance, this.configPath, "Settings", "DelayVariance")
            IniWrite(this.startupEnabled, this.configPath, "Settings", "StartupEnabled")
            IniWrite(this.firstRun, this.configPath, "Settings", "FirstRun")
            return true
        } catch as err {
            MsgBox("配置保存失败: " err.Message, "错误", "Icon!")
            return false
        }
    }
    
    CreateDefaultConfig() {
        this.delayMode := "Standard"
        this.baseDelay := 30
        this.delayVariance := 15
        this.startupEnabled := 0
        this.firstRun := 1
        this.SaveConfig()
    }
    
    GetDelayMode() => this.delayMode
    SetDelayMode(mode) => (this.delayMode := mode, true)
    GetBaseDelay() => this.baseDelay
    SetBaseDelay(value) => (this.baseDelay := Integer(value), true)
    GetDelayVariance() => this.delayVariance
    SetDelayVariance(value) => (this.delayVariance := Integer(value), true)
    IsStartupEnabled() => this.startupEnabled = 1
    SetStartupEnabled(enabled) => (this.startupEnabled := enabled ? 1 : 0, true)
}

; ============================================================================
; 简化的 Delay_Algorithm 类（用于测试）
; ============================================================================
class Delay_Algorithm {
    configManager := ""
    
    __New(configMgr) {
        this.configManager := configMgr
    }
    
    GetPresetValues(mode) {
        switch mode {
            case "Fast":
                return {baseDelay: 10, variance: 5}
            case "Standard":
                return {baseDelay: 30, variance: 15}
            case "Conservative":
                return {baseDelay: 50, variance: 25}
            default:
                return {baseDelay: 30, variance: 15}
        }
    }
}

; ============================================================================
; 简化的 Startup_Manager 类（用于测试）
; ============================================================================
class Startup_Manager {
    regKey := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    regValueName := "YouCanCopyAndPasteV2Test"
    
    __New() {
    }
    
    EnableStartup(scriptPath) {
        try {
            RegWrite(scriptPath, "REG_SZ", this.regKey, this.regValueName)
            MsgBox("已启用开机自启动（测试模式）", "提示", "Iconi")
            return true
        } catch as err {
            MsgBox("启用开机自启动失败: " err.Message, "错误", "Icon!")
            return false
        }
    }
    
    DisableStartup() {
        try {
            RegDelete(this.regKey, this.regValueName)
            MsgBox("已禁用开机自启动（测试模式）", "提示", "Iconi")
            return true
        } catch {
            return true
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
    
    IsAdmin() {
        return A_IsAdmin
    }
    
    RequestAdminElevation(scriptPath := "") {
        if (this.IsAdmin()) {
            MsgBox("当前已以管理员权限运行", "提示", "Iconi")
            return true
        }
        
        if (scriptPath = "") {
            scriptPath := A_ScriptFullPath
        }
        
        try {
            Run("*RunAs " scriptPath)
            ExitApp
            return true
        } catch as err {
            MsgBox("管理员权限提升失败: " err.Message, "错误", "Icon!")
            return false
        }
    }
}

; ============================================================================
; UI_Manager 类（包含 Task 8.3 的实现）
; ============================================================================
class UI_Manager {
    configManager := ""
    startupManager := ""
    
    __New(configMgr, startupMgr) {
        this.configManager := configMgr
        this.startupManager := startupMgr
    }
    
    ; 显示设置界面
    ShowSettingsWindow() {
        ; 创建 GUI 窗口
        settingsGui := Gui("+AlwaysOnTop", "设置")
        
        ; 设置字体为 Microsoft YaHei
        settingsGui.SetFont("s10", "Microsoft YaHei")
        
        ; ========== 延迟模式下拉菜单 ==========
        settingsGui.Add("Text", "w400", "延迟模式：")
        delayModeDropdown := settingsGui.Add("DropDownList", "w400", ["Fast", "Standard", "Conservative"])
        
        ; 设置当前延迟模式
        currentMode := this.configManager.GetDelayMode()
        switch currentMode {
            case "Fast":
                delayModeDropdown.Choose(1)
            case "Standard":
                delayModeDropdown.Choose(2)
            case "Conservative":
                delayModeDropdown.Choose(3)
            default:
                delayModeDropdown.Choose(2)
        }
        
        ; ========== 基础延迟输入框 ==========
        settingsGui.Add("Text", "w400 Section", "基础延迟 (Base Delay)：")
        baseDelayEdit := settingsGui.Add("Edit", "w300 Number")
        baseDelayEdit.Value := this.configManager.GetBaseDelay()
        settingsGui.Add("Text", "x+10 yp", "毫秒 (ms)")
        
        ; ========== 波动范围输入框 ==========
        settingsGui.Add("Text", "w400 xs", "波动范围 (Variance)：")
        varianceEdit := settingsGui.Add("Edit", "w300 Number")
        varianceEdit.Value := this.configManager.GetDelayVariance()
        settingsGui.Add("Text", "x+10 yp", "毫秒 (ms)")
        
        ; ========== 开机自启动复选框 ==========
        ; 读取实际的注册表状态
        actualStartupState := this.startupManager.IsStartupEnabled()
        startupCheckbox := settingsGui.Add("Checkbox", "w400 xs", "开机自启动")
        startupCheckbox.Value := actualStartupState ? 1 : 0
        
        ; ========== 管理员权限部分 ==========
        settingsGui.Add("Text", "w400 xs Section", "管理员权限：")
        
        ; 显示当前管理员权限状态
        adminStatus := this.startupManager.IsAdmin() ? "当前状态：已以管理员权限运行" : "当前状态：普通权限运行"
        adminStatusText := settingsGui.Add("Text", "w400 xs", adminStatus)
        
        ; 添加"请求管理员权限"按钮
        adminBtn := settingsGui.Add("Button", "w200 xs", "请求管理员权限")
        adminBtn.OnEvent("Click", (*) => this.OnRequestAdminClick())
        
        ; ========== 保存和取消按钮 ==========
        settingsGui.Add("Text", "w400 xs")  ; 添加间距
        
        ; "保存"按钮
        saveBtn := settingsGui.Add("Button", "w180 h35 xs", "保存")
        saveBtn.OnEvent("Click", (*) => this.OnSaveSettingsClick(settingsGui, delayModeDropdown, baseDelayEdit, varianceEdit, startupCheckbox))
        
        ; "取消"按钮（放在同一行）
        cancelBtn := settingsGui.Add("Button", "x+20 w180 h35", "取消")
        cancelBtn.OnEvent("Click", (*) => settingsGui.Destroy())
        
        ; ========== 延迟模式切换事件 ==========
        ; 当延迟模式改变时，自动更新基础延迟和波动范围字段
        delayModeDropdown.OnEvent("Change", (*) => this.OnDelayModeChange(delayModeDropdown, baseDelayEdit, varianceEdit))
        
        ; 显示窗口
        settingsGui.Show()
    }
    
    ; 延迟模式切换处理
    OnDelayModeChange(dropdown, baseDelayEdit, varianceEdit) {
        ; 获取选中的模式
        selectedMode := dropdown.Text
        
        ; 获取预设值
        delayAlgo := Delay_Algorithm(this.configManager)
        presetValues := delayAlgo.GetPresetValues(selectedMode)
        
        ; 更新输入框的值
        baseDelayEdit.Value := presetValues.baseDelay
        varianceEdit.Value := presetValues.variance
    }
    
    ; 请求管理员权限按钮处理
    OnRequestAdminClick() {
        ; 调用 Startup_Manager 的 RequestAdminElevation 方法
        this.startupManager.RequestAdminElevation()
    }
    
    ; 保存设置按钮处理
    OnSaveSettingsClick(settingsGui, delayModeDropdown, baseDelayEdit, varianceEdit, startupCheckbox) {
        ; 获取用户输入的值
        selectedMode := delayModeDropdown.Text
        baseDelay := baseDelayEdit.Value
        variance := varianceEdit.Value
        startupEnabled := startupCheckbox.Value
        
        ; 验证输入
        if (!this.ValidateInput(baseDelay, variance)) {
            return  ; 验证失败，不保存
        }
        
        ; 保存延迟模式
        this.configManager.SetDelayMode(selectedMode)
        
        ; 保存基础延迟
        this.configManager.SetBaseDelay(baseDelay)
        
        ; 保存波动范围
        this.configManager.SetDelayVariance(variance)
        
        ; 处理开机自启动设置
        ; 获取当前实际的注册表状态
        currentStartupState := this.startupManager.IsStartupEnabled()
        
        ; 只有当用户的选择与当前状态不同时，才进行修改
        if (startupEnabled && !currentStartupState) {
            ; 用户勾选了自启动，但当前未启用 -> 启用自启动
            this.startupManager.EnableStartup(A_ScriptFullPath)
            this.configManager.SetStartupEnabled(1)
        } else if (!startupEnabled && currentStartupState) {
            ; 用户取消了自启动，但当前已启用 -> 禁用自启动
            this.startupManager.DisableStartup()
            this.configManager.SetStartupEnabled(0)
        } else {
            ; 状态未改变，只更新配置文件中的值以保持一致
            this.configManager.SetStartupEnabled(startupEnabled ? 1 : 0)
        }
        
        ; 保存配置到文件
        if (this.configManager.SaveConfig()) {
            ; 显示保存成功提示
            ToolTip("设置已保存")
            SetTimer(() => ToolTip(), -1000)
            
            ; 显示保存的配置信息
            MsgBox("设置已保存！`n`n延迟模式: " selectedMode "`n基础延迟: " baseDelay " ms`n波动范围: " variance " ms`n开机自启动: " (startupEnabled ? "已启用" : "已禁用"), "保存成功", "Iconi")
            
            ; 关闭设置窗口
            settingsGui.Destroy()
        } else {
            ; 保存失败（Config_Manager 会显示错误消息）
            ; 不关闭窗口，让用户可以重试
        }
    }
    
    ; 验证用户输入
    ValidateInput(baseDelay, variance) {
        ; 验证基础延迟（1-1000ms）
        if (baseDelay < 1 || baseDelay > 1000) {
            MsgBox("基础延迟必须在 1-1000 毫秒之间", "输入错误", "Icon!")
            return false
        }
        
        ; 验证波动范围（0-500ms）
        if (variance < 0 || variance > 500) {
            MsgBox("波动范围必须在 0-500 毫秒之间", "输入错误", "Icon!")
            return false
        }
        
        ; 验证输入为正整数（AutoHotkey 的 Number 选项已确保这一点）
        ; 但我们仍然检查一下
        if (!IsInteger(baseDelay) || !IsInteger(variance)) {
            MsgBox("延迟值必须为整数", "输入错误", "Icon!")
            return false
        }
        
        return true
    }
}

; ============================================================================
; 测试主程序
; ============================================================================

; 创建实例
global configManager := Config_Manager(A_ScriptDir)
configManager.LoadConfig()

global startupManager := Startup_Manager()
global uiManager := UI_Manager(configManager, startupManager)

; 显示设置窗口
uiManager.ShowSettingsWindow()

; 保持脚本运行
Persistent
