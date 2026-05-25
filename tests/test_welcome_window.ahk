#Requires AutoHotkey v2.0
#SingleInstance Force

; 简单测试脚本 - 仅测试欢迎窗口

; 模拟 Config_Manager（简化版）
class Config_Manager {
    configPath := ""
    firstRun := 1
    
    __New(scriptDir) {
        this.configPath := scriptDir "\config.ini"
    }
    
    IsFirstRun() {
        return this.firstRun = 1
    }
    
    SetFirstRun(value) {
        this.firstRun := value ? 1 : 0
        return true
    }
    
    SaveConfig() {
        MsgBox("配置已保存（测试模式）", "提示", "Iconi")
        return true
    }
}

; 模拟 Startup_Manager（简化版）
class Startup_Manager {
    __New() {
    }
}

; UI_Manager 类
class UI_Manager {
    configManager := ""
    startupManager := ""
    
    __New(configMgr, startupMgr) {
        this.configManager := configMgr
        this.startupManager := startupMgr
    }
    
    ; 显示欢迎界面
    ShowWelcomeWindow() {
        ; 创建 GUI 窗口
        welcomeGui := Gui("+AlwaysOnTop", "欢迎使用")
        
        ; 设置字体为 Microsoft YaHei
        welcomeGui.SetFont("s10", "Microsoft YaHei")
        
        ; 添加标题文本
        welcomeGui.SetFont("s16 Bold", "Microsoft YaHei")
        welcomeGui.Add("Text", "Center w400", "Force-Copy-And-Paste-least v2.0")
        
        ; 恢复正常字体
        welcomeGui.SetFont("s10 Normal", "Microsoft YaHei")
        
        ; 添加工具描述文本
        descriptionText := "
        (
        突破在线代码评测沙箱的粘贴限制工具
        
        通过模拟物理键盘输入，将剪贴板内容注入到
        禁止粘贴的编辑器（如 Monaco Editor、CodeMirror）中。
        )"
        welcomeGui.Add("Text", "Center w400", descriptionText)
        
        ; 添加分隔线
        welcomeGui.Add("Text", "w400 0x10")
        
        ; 添加快捷键说明标题
        welcomeGui.SetFont("s11 Bold", "Microsoft YaHei")
        welcomeGui.Add("Text", "w400", "快捷键说明：")
        
        ; 恢复正常字体
        welcomeGui.SetFont("s10 Normal", "Microsoft YaHei")
        
        ; 添加快捷键说明
        hotkeyText := "
        (
        • Shift + Esc：紧急停止（重载脚本）
        • Ctrl + Insert：强力复制
        • Shift + Insert：强力粘贴（沙箱穿透）
        )"
        welcomeGui.Add("Text", "w400", hotkeyText)
        
        ; 添加分隔线
        welcomeGui.Add("Text", "w400 0x10")
        
        ; 添加按钮容器（使用水平布局）
        ; "进入设置"按钮
        settingsBtn := welcomeGui.Add("Button", "w180 h35", "进入设置")
        settingsBtn.OnEvent("Click", (*) => this.OnWelcomeSettingsClick(welcomeGui))
        
        ; "开始使用"按钮（放在同一行）
        startBtn := welcomeGui.Add("Button", "x+20 w180 h35", "开始使用")
        startBtn.OnEvent("Click", (*) => this.OnWelcomeStartClick(welcomeGui))
        
        ; 显示窗口
        welcomeGui.Show()
    }
    
    ; 欢迎界面 - "进入设置"按钮点击处理
    OnWelcomeSettingsClick(welcomeGui) {
        ; 关闭欢迎窗口
        welcomeGui.Destroy()
        
        ; 打开设置窗口
        this.ShowSettingsWindow()
    }
    
    ; 欢迎界面 - "开始使用"按钮点击处理
    OnWelcomeStartClick(welcomeGui) {
        ; 设置 FirstRun=0
        this.configManager.SetFirstRun(0)
        
        ; 保存配置
        this.configManager.SaveConfig()
        
        ; 关闭欢迎窗口
        welcomeGui.Destroy()
        
        ; 退出测试脚本
        ExitApp
    }
    
    ; 显示设置界面（占位方法）
    ShowSettingsWindow() {
        MsgBox("设置功能将在后续任务中实现", "提示", "Iconi")
        ExitApp
    }
}

; 创建实例
configManager := Config_Manager(A_ScriptDir)
startupManager := Startup_Manager()
uiManager := UI_Manager(configManager, startupManager)

; 显示欢迎窗口
uiManager.ShowWelcomeWindow()
