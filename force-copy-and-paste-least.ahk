#Requires AutoHotkey v2.0

; ============================================================================
; force-copy-and-paste-least - AutoHotkey v2 效率工具
; 提供增强的复制粘贴功能，支持延迟注入、文本净化和完整的配置管理
; ============================================================================

; ============================================================================
; 全局配置变量
; ============================================================================
global g_DelayMode := "fixed"        ; "fixed" 或 "random"
global g_BaseDelay := 15             ; 基础延迟（毫秒）
global g_MaxJitter := 50             ; 最大波动延迟（毫秒）
global g_AutoStart := false          ; 开机自启状态

; 运行时状态
global g_ConfigFile := A_ScriptDir "\config.ini"
global g_SettingsGui := ""           ; GUI 对象引用
global g_TipTimer := ""              ; 提示计时器引用

; ============================================================================
; 配置管理模块 (Config_Manager)
; ============================================================================

; 加载配置
Config_Load() {
    global g_ConfigFile, g_DelayMode, g_BaseDelay, g_MaxJitter, g_AutoStart
    
    ; 检查配置文件是否存在
    if (!FileExist(g_ConfigFile)) {
        Config_CreateDefault()
        return
    }
    
    ; 读取配置
    try {
        g_DelayMode := IniRead(g_ConfigFile, "Settings", "DelayMode", "fixed")
        g_BaseDelay := Integer(IniRead(g_ConfigFile, "Settings", "BaseDelay", "15"))
        g_MaxJitter := Integer(IniRead(g_ConfigFile, "Settings", "MaxJitter", "50"))
        autoStartStr := IniRead(g_ConfigFile, "Settings", "AutoStart", "0")
        g_AutoStart := (autoStartStr = "1")
    } catch {
        ; 配置文件格式错误，使用默认配置
        Feedback_ShowTip("配置文件格式错误，已使用默认设置")
        Config_CreateDefault()
    }
}

; 创建默认配置
Config_CreateDefault() {
    global g_ConfigFile, g_DelayMode, g_BaseDelay, g_MaxJitter, g_AutoStart
    
    try {
        IniWrite("fixed", g_ConfigFile, "Settings", "DelayMode")
        IniWrite("15", g_ConfigFile, "Settings", "BaseDelay")
        IniWrite("50", g_ConfigFile, "Settings", "MaxJitter")
        IniWrite("0", g_ConfigFile, "Settings", "AutoStart")
        
        ; 加载默认值到全局变量
        g_DelayMode := "fixed"
        g_BaseDelay := 15
        g_MaxJitter := 50
        g_AutoStart := false
    } catch {
        ; 配置文件创建失败，仅使用内存中的默认值
    }
}

; 保存配置
Config_Save(delayMode, baseDelay, maxJitter, autoStart) {
    global g_ConfigFile, g_DelayMode, g_BaseDelay, g_MaxJitter, g_AutoStart
    
    try {
        IniWrite(delayMode, g_ConfigFile, "Settings", "DelayMode")
        IniWrite(String(baseDelay), g_ConfigFile, "Settings", "BaseDelay")
        IniWrite(String(maxJitter), g_ConfigFile, "Settings", "MaxJitter")
        IniWrite(autoStart ? "1" : "0", g_ConfigFile, "Settings", "AutoStart")
        
        ; 更新全局变量
        g_DelayMode := delayMode
        g_BaseDelay := baseDelay
        g_MaxJitter := maxJitter
        g_AutoStart := autoStart
        
        ; 更新开机自启
        Startup_Update(autoStart)
        
        return true
    } catch {
        return false
    }
}

; 验证配置值
Config_Validate(baseDelay, maxJitter) {
    if (!IsNumber(baseDelay) || baseDelay < 0) {
        return "基础延迟必须大于等于 0"
    }
    if (!IsNumber(maxJitter) || maxJitter < 0) {
        return "最大波动延迟必须大于等于 0"
    }
    return ""
}

; ============================================================================
; 剪贴板管理模块 (Clipboard_Manager)
; ============================================================================

; 清空剪贴板
Clipboard_Clear() {
    A_Clipboard := ""
}

; 等待剪贴板更新
Clipboard_Wait(timeout := 1) {
    return ClipWait(timeout)
}

; 读取剪贴板内容
Clipboard_Read() {
    return A_Clipboard
}

; ============================================================================
; 反馈提示系统 (Feedback_System)
; ============================================================================

; 显示提示信息
Feedback_ShowTip(msg) {
    global g_TipTimer
    
    ; 取消之前的计时器
    if (g_TipTimer != "") {
        SetTimer(g_TipTimer, 0)
    }
    
    ; 显示提示
    ToolTip(msg)
    
    ; 设置自动隐藏计时器
    g_TipTimer := () => ToolTip()
    SetTimer(g_TipTimer, -2000)
}

; ============================================================================
; 文本净化模块 (Text_Sanitizer)
; ============================================================================

; 净化文本
Text_Sanitize(text) {
    ; 去除首尾空白
    text := Trim(text)
    
    ; 合并连续空行为单个换行符
    text := RegExReplace(text, "\R{2,}", "`n")
    
    return text
}

; ============================================================================
; 延迟注入模块 (Delay_Injector)
; ============================================================================

; 延迟注入文本
Delay_Inject(text) {
    global g_DelayMode, g_BaseDelay, g_MaxJitter
    
    if (g_DelayMode = "fixed") {
        ; 固定延迟模式
        SetKeyDelay(g_BaseDelay)
        SendText(text)
    } else {
        ; 随机延迟模式
        Loop Parse, text {
            SendText(A_LoopField)
            Sleep(Random(g_BaseDelay, g_BaseDelay + g_MaxJitter))
        }
    }
}

; ============================================================================
; 强力复制处理器 (Copy_Handler)
; ============================================================================

; 执行强力复制操作
Copy_Execute() {
    ; 等待修饰键释放
    KeyWait("Ctrl")
    KeyWait("Shift")
    Sleep(100)
    
    ; 清空剪贴板
    Clipboard_Clear()
    
    ; 发送底层复制指令
    Send("^{Insert}")
    
    ; 等待剪贴板更新
    if (Clipboard_Wait(1)) {
        Feedback_ShowTip("已复制")
    } else {
        Feedback_ShowTip("复制失败")
    }
}

; ============================================================================
; 智能粘贴处理器 (Paste_Handler)
; ============================================================================

; 执行智能粘贴操作
Paste_Execute() {
    ; 等待修饰键释放
    KeyWait("Ctrl")
    KeyWait("Shift")
    Sleep(100)
    
    ; 读取剪贴板
    text := Clipboard_Read()
    if (text = "") {
        Feedback_ShowTip("剪贴板为空")
        return
    }
    
    ; 净化文本
    cleanText := Text_Sanitize(text)
    
    ; 延迟注入
    Delay_Inject(cleanText)
    
    ; 显示反馈
    Feedback_ShowTip("已粘贴")
}

; ============================================================================
; 开机自启管理模块 (Startup_Manager)
; ============================================================================

; 更新开机自启状态
Startup_Update(enable) {
    shortcutPath := A_Startup "\force-copy-and-paste-least.lnk"
    
    if (enable) {
        try {
            FileCreateShortcut(A_ScriptFullPath, shortcutPath)
        } catch {
            Feedback_ShowTip("自启设置失败，请检查启动文件夹权限")
        }
    } else {
        try {
            if (FileExist(shortcutPath)) {
                FileDelete(shortcutPath)
            }
        }
    }
}

; 检查是否已设置开机自启
Startup_IsEnabled() {
    return FileExist(A_Startup "\force-copy-and-paste-least.lnk") ? true : false
}

; ============================================================================
; 图形界面管理模块 (GUI_Manager)
; ============================================================================

; 创建设置窗口
GUI_Create() {
    myGui := Gui("+AlwaysOnTop", "force-copy-and-paste-least 设置")
    
    ; 尝试使用 Microsoft YaHei，如果不可用则使用 Segoe UI
    myGui.SetFont("s10", "Microsoft YaHei")
    
    ; 延迟模式组
    myGui.SetFont("s12 Bold")
    myGui.Add("GroupBox", "x10 y10 w360 h80", "延迟模式")
    myGui.SetFont("s10 Norm")
    
    radioFixed := myGui.Add("Radio", "x30 y35 vDelayModeFixed", "固定延迟")
    radioRandom := myGui.Add("Radio", "x30 y60 vDelayModeRandom", "随机延迟")
    
    ; 时间参数组
    myGui.SetFont("s12 Bold")
    myGui.Add("GroupBox", "x10 y100 w360 h100", "时间参数")
    myGui.SetFont("s10 Norm")
    
    myGui.Add("Text", "x30 y125", "基础延迟(ms):")
    editBase := myGui.Add("Edit", "x150 y122 w200 vBaseDelay Number")
    
    myGui.Add("Text", "x30 y160", "最大波动延迟(ms):")
    editJitter := myGui.Add("Edit", "x150 y157 w200 vMaxJitter Number")
    
    ; 开机自启
    checkAutoStart := myGui.Add("Checkbox", "x10 y215 vAutoStart", "开机自启")
    
    ; 保存按钮
    btnSave := myGui.Add("Button", "x10 y250 w360 h40", "保存")
    btnSave.OnEvent("Click", GUI_OnSave)
    
    ; 延迟模式切换事件
    radioFixed.OnEvent("Click", (*) => editJitter.Enabled := false)
    radioRandom.OnEvent("Click", (*) => editJitter.Enabled := true)
    
    ; 保存 GUI 引用
    global g_SettingsGui := myGui
    
    return myGui
}

; 显示设置窗口
GUI_Show() {
    global g_SettingsGui, g_DelayMode, g_BaseDelay, g_MaxJitter, g_AutoStart
    
    if (g_SettingsGui = "") {
        GUI_Create()
    }
    
    ; 加载当前配置
    if (g_DelayMode = "fixed") {
        g_SettingsGui["DelayModeFixed"].Value := 1
        g_SettingsGui["MaxJitter"].Enabled := false
    } else {
        g_SettingsGui["DelayModeRandom"].Value := 1
        g_SettingsGui["MaxJitter"].Enabled := true
    }
    
    g_SettingsGui["BaseDelay"].Value := g_BaseDelay
    g_SettingsGui["MaxJitter"].Value := g_MaxJitter
    g_SettingsGui["AutoStart"].Value := g_AutoStart
    
    g_SettingsGui.Show()
}

; 保存按钮点击事件
GUI_OnSave(*) {
    global g_SettingsGui
    
    ; 获取表单值
    saved := g_SettingsGui.Submit(false)
    
    delayMode := saved.DelayModeFixed ? "fixed" : "random"
    baseDelay := Integer(saved.BaseDelay)
    maxJitter := Integer(saved.MaxJitter)
    autoStart := saved.AutoStart
    
    ; 验证输入
    errMsg := Config_Validate(baseDelay, maxJitter)
    if (errMsg != "") {
        MsgBox(errMsg, "输入错误", "Icon!")
        return
    }
    
    ; 保存配置
    if (Config_Save(delayMode, baseDelay, maxJitter, autoStart)) {
        Feedback_ShowTip("配置已保存")
        g_SettingsGui.Hide()
    } else {
        MsgBox("配置保存失败，请检查文件权限", "保存失败", "IconX")
    }
}

; ============================================================================
; 托盘菜单管理模块 (Tray_Manager)
; ============================================================================

; 初始化托盘菜单
Tray_Init() {
    ; 删除默认菜单
    A_TrayMenu.Delete()
    
    ; 添加自定义菜单
    A_TrayMenu.Add("设置", (*) => GUI_Show())
    A_TrayMenu.Add("休眠/唤醒", Tray_ToggleSuspend)
    A_TrayMenu.Add("退出", (*) => ExitApp())
}

; 切换休眠状态
Tray_ToggleSuspend(*) {
    Suspend(-1)  ; 切换挂起状态
    
    if (A_IsSuspended) {
        ; 已挂起
        A_TrayMenu.Rename("休眠/唤醒", "唤醒")
        Feedback_ShowTip("热键已休眠")
    } else {
        ; 已唤醒
        A_TrayMenu.Rename("唤醒", "休眠/唤醒")
        Feedback_ShowTip("热键已唤醒")
    }
}

; ============================================================================
; 热键管理模块 (Hotkey_Manager)
; ============================================================================

; 注册所有热键
Hotkey_Register() {
    ; 强力复制
    Hotkey("^+c", (*) => Copy_Execute())
    
    ; 强力粘贴
    Hotkey("^+v", (*) => Paste_Execute())
    
    ; 紧急停止
    Hotkey("Esc", (*) => Reload())
}

; ============================================================================
; 主程序初始化
; ============================================================================

; 加载配置
Config_Load()

; 初始化托盘菜单
Tray_Init()

; 注册热键
Hotkey_Register()

; 程序保持运行
