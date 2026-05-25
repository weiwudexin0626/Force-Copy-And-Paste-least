; ============================================================================
; Force-Copy-And-Paste-least v2.0
; 突破在线代码评测沙箱的粘贴限制工具
; ============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; 设置脚本基本属性
Persistent
A_IconHidden := true

; ============================================================================
; Config_Manager 类 - 配置管理器
; ============================================================================
class Config_Manager {
    ; 配置属性
    configPath := ""
    delayMode := "Standard"
    baseDelay := 30
    delayVariance := 15
    startupEnabled := 0
    firstRun := 1
    
    ; 构造函数
    __New(scriptDir) {
        this.configPath := scriptDir "\config.ini"
    }
    
    ; 从 config.ini 加载配置
    LoadConfig() {
        try {
            ; 检查配置文件是否存在
            if !FileExist(this.configPath) {
                this.CreateDefaultConfig()
                return
            }
            
            ; 读取配置项
            this.delayMode := IniRead(this.configPath, "Settings", "DelayMode", "Standard")
            this.baseDelay := Integer(IniRead(this.configPath, "Settings", "BaseDelay", "30"))
            this.delayVariance := Integer(IniRead(this.configPath, "Settings", "DelayVariance", "15"))
            this.startupEnabled := Integer(IniRead(this.configPath, "Settings", "StartupEnabled", "0"))
            this.firstRun := Integer(IniRead(this.configPath, "Settings", "FirstRun", "1"))
            
            ; 验证配置值的有效性
            if !this.ValidateConfig() {
                throw Error("配置文件损坏")
            }
        } catch as err {
            ; 配置文件损坏时自动重建
            ToolTip("配置文件读取失败，已重建默认配置: " err.Message)
            SetTimer(() => ToolTip(), -2000)
            this.CreateDefaultConfig()
        }
    }
    
    ; 保存配置到 config.ini
    SaveConfig() {
        try {
            IniWrite(this.delayMode, this.configPath, "Settings", "DelayMode")
            IniWrite(this.baseDelay, this.configPath, "Settings", "BaseDelay")
            IniWrite(this.delayVariance, this.configPath, "Settings", "DelayVariance")
            IniWrite(this.startupEnabled, this.configPath, "Settings", "StartupEnabled")
            IniWrite(this.firstRun, this.configPath, "Settings", "FirstRun")
            return true
        } catch as err {
            ; 保存失败时显示错误消息
            MsgBox("配置保存失败: " err.Message, "错误", "Icon!")
            return false
        }
    }
    
    ; 创建默认配置文件
    CreateDefaultConfig() {
        try {
            ; 重置为默认值
            this.delayMode := "Standard"
            this.baseDelay := 30
            this.delayVariance := 15
            this.startupEnabled := 0
            this.firstRun := 1
            
            ; 保存到文件
            this.SaveConfig()
        } catch as err {
            ; 创建默认配置失败
            MsgBox("创建默认配置文件失败: " err.Message "`n`n脚本将使用内存中的默认值运行", "错误", "Icon!")
        }
    }
    
    ; 验证配置值的有效性
    ValidateConfig() {
        ; 验证延迟模式
        if !(this.delayMode = "Fast" || this.delayMode = "Standard" || this.delayMode = "Conservative") {
            return false
        }
        
        ; 验证基础延迟（1-1000ms）
        if (this.baseDelay < 1 || this.baseDelay > 1000) {
            return false
        }
        
        ; 验证延迟波动（0-500ms）
        if (this.delayVariance < 0 || this.delayVariance > 500) {
            return false
        }
        
        ; 验证布尔值
        if !(this.startupEnabled = 0 || this.startupEnabled = 1) {
            return false
        }
        
        if !(this.firstRun = 0 || this.firstRun = 1) {
            return false
        }
        
        return true
    }
    
    ; Getter/Setter 方法
    GetDelayMode() {
        return this.delayMode
    }
    
    SetDelayMode(mode) {
        if (mode = "Fast" || mode = "Standard" || mode = "Conservative") {
            this.delayMode := mode
            return true
        }
        return false
    }
    
    GetBaseDelay() {
        return this.baseDelay
    }
    
    SetBaseDelay(value) {
        if (value >= 1 && value <= 1000) {
            this.baseDelay := Integer(value)
            return true
        }
        return false
    }
    
    GetDelayVariance() {
        return this.delayVariance
    }
    
    SetDelayVariance(value) {
        if (value >= 0 && value <= 500) {
            this.delayVariance := Integer(value)
            return true
        }
        return false
    }
    
    IsStartupEnabled() {
        return this.startupEnabled = 1
    }
    
    SetStartupEnabled(enabled) {
        this.startupEnabled := enabled ? 1 : 0
        return true
    }
    
    IsFirstRun() {
        return this.firstRun = 1
    }
    
    SetFirstRun(value) {
        this.firstRun := value ? 1 : 0
        return true
    }
}

; ============================================================================
; Delay_Algorithm 类 - 延迟算法
; ============================================================================
class Delay_Algorithm {
    ; 配置管理器引用
    configManager := ""
    
    ; 构造函数
    __New(configMgr) {
        this.configManager := configMgr
    }
    
    ; 获取预设模式的参数
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
    
    ; 生成随机延迟值
    GenerateDelay() {
        try {
            ; 从配置管理器获取当前设置
            baseDelay := this.configManager.GetBaseDelay()
            variance := this.configManager.GetDelayVariance()
            
            ; 计算延迟范围
            minDelay := baseDelay - variance
            maxDelay := baseDelay + variance
            
            ; 确保最小值不小于 1ms
            if (minDelay < 1) {
                minDelay := 1
            }
            
            ; 生成随机延迟值
            randomDelay := Random(minDelay, maxDelay)
            
            return randomDelay
        } catch as err {
            ; 延迟生成失败，返回默认值 30ms
            ToolTip("延迟生成失败，使用默认值: " err.Message)
            SetTimer(() => ToolTip(), -1000)
            return 30
        }
    }
}

; ============================================================================
; AutoExecute 段 - 脚本启动初始化流程
; ============================================================================

; 创建 Config_Manager 实例
global configManager := Config_Manager(A_ScriptDir)

; 加载配置（如果 config.ini 不存在，会自动创建默认配置）
configManager.LoadConfig()

; ============================================================================
; Clipboard_Processor 类 - 剪贴板处理器
; ============================================================================
class Clipboard_Processor {
    ; 获取剪贴板文本内容
    GetClipboardText() {
        try {
            ; 读取剪贴板文本
            clipText := A_Clipboard
            return clipText
        } catch as err {
            ; 剪贴板访问失败
            ToolTip("剪贴板访问失败: " err.Message)
            SetTimer(() => ToolTip(), -1500)
            return ""
        }
    }
    
    ; 检查剪贴板是否为空
    IsClipboardEmpty() {
        clipText := this.GetClipboardText()
        ; 检查是否为空或仅包含空白字符
        return (clipText = "" || Trim(clipText) = "")
    }
    
    ; 文本消毒处理
    SanitizeText(rawText) {
        try {
            ; 如果输入为空，直接返回
            if (rawText = "") {
                return ""
            }
            
            sanitized := rawText
            
            ; 1. 移除所有 \r (CR) 字符
            sanitized := StrReplace(sanitized, "`r", "")
            
            ; 2. 将 \t (Tab) 替换为 4 个空格
            sanitized := StrReplace(sanitized, "`t", "    ")
            
            ; 3. 将 Chr(160) (NBSP) 替换为普通空格
            sanitized := StrReplace(sanitized, Chr(160), " ")
            
            ; 4. 使用 RegExReplace 清除零宽字符和 BOM 标记
            ; 零宽字符包括：
            ; - U+200B (Zero Width Space)
            ; - U+200C (Zero Width Non-Joiner)
            ; - U+200D (Zero Width Joiner)
            ; - U+FEFF (Zero Width No-Break Space / BOM)
            ; - U+2060 (Word Joiner)
            sanitized := RegExReplace(sanitized, "[\x{200B}\x{200C}\x{200D}\x{FEFF}\x{2060}]", "")
            
            ; 保留 \n 字符用于行分割（不需要额外处理）
            
            return sanitized
        } catch as err {
            ; 文本消毒失败，返回原始文本
            ToolTip("警告: 文本消毒失败，使用原始文本")
            SetTimer(() => ToolTip(), -1000)
            return rawText
        }
    }
}

; ============================================================================
; Injection_Engine 类 - 注入引擎
; ============================================================================
class Injection_Engine {
    ; 依赖
    delayAlgorithm := ""
    
    ; 注入状态属性
    isInjecting := false        ; 当前是否正在注入
    currentLine := 0            ; 当前注入的行号
    totalLines := 0             ; 总行数
    
    ; 构造函数
    __New(delayAlgo) {
        this.delayAlgorithm := delayAlgo
    }
    
    ; 释放所有修饰键
    ReleaseModifierKeys() {
        try {
            ; 使用 SendEvent 发送所有修饰键的 key-up 事件
            ; {Blind} 模式确保不干扰其他按键状态
            SendEvent("{Blind}{Ctrl up}{Shift up}{Alt up}{LWin up}{RWin up}")
            
            ; 等待 50ms 确保按键释放完成
            Sleep(50)
        } catch as err {
            ; 释放修饰键失败，记录错误但不中断流程
            ToolTip("警告: 修饰键释放失败 - " err.Message)
            SetTimer(() => ToolTip(), -1500)
        }
    }
    
    ; 逐行注入功能
    InjectLine(lineText) {
        try {
            ; 设置发送模式为 Event 模式
            SendMode("Event")
            
            ; 设置按键延迟：-1 表示无延迟，0 表示按下和释放之间无延迟
            SetKeyDelay(-1, 0)
            
            ; 使用 {Text} 参数发送整行文本
            ; {Text} 模式会将文本作为原始字符发送，防止输入法干扰
            SendEvent("{Text}" lineText)
            
            ; 发送回车键
            SendEvent("{Enter}")
            
            ; 等待 30ms 让编辑器渲染
            Sleep(30)
        } catch as err {
            ; 注入单行失败，抛出错误让上层处理
            throw Error("注入第 " this.currentLine " 行失败: " err.Message)
        }
    }
    
    ; 主注入流程
    InjectText(sanitizedText) {
        try {
            ; 释放修饰键
            this.ReleaseModifierKeys()
            
            ; 按行分割文本
            lines := StrSplit(sanitizedText, "`n")
            
            ; 记录总行数
            this.totalLines := lines.Length
            this.currentLine := 0
            this.isInjecting := true
            
            ; 显示开始注入提示
            ToolTip("开始注入...")
            
            ; 遍历每一行
            for index, lineText in lines {
                ; 更新当前行号
                this.currentLine := index
                
                ; 注入当前行
                try {
                    this.InjectLine(lineText)
                } catch as lineErr {
                    ; 单行注入失败，记录错误并继续
                    ToolTip("警告: 第 " index " 行注入失败，继续注入...")
                    SetTimer(() => ToolTip(), -1000)
                    Sleep(500)
                }
                
                ; 生成并等待随机延迟
                delay := this.delayAlgorithm.GenerateDelay()
                Sleep(delay)
                
                ; 每 10 行更新一次进度
                if (Mod(index, 10) = 0) {
                    this.ShowProgress(index, this.totalLines)
                }
            }
            
            ; 注入完成
            this.isInjecting := false
            
            ; 显示完成提示
            ToolTip("注入完成，共 " this.totalLines " 行")
            
            ; 1 秒后自动清除提示
            SetTimer(() => ToolTip(), -1000)
        } catch as err {
            ; 注入过程中发生严重错误
            this.isInjecting := false
            
            ; 显示错误提示
            ToolTip("注入失败: " err.Message "`n已注入 " this.currentLine " / " this.totalLines " 行")
            SetTimer(() => ToolTip(), -3000)
        }
    }
    
    ; 显示注入进度
    ShowProgress(currentLine, totalLines) {
        try {
            ; 显示当前进度的 ToolTip
            ToolTip("已注入 " currentLine " / " totalLines " 行")
            
            ; 使用 SetTimer 在 1000ms 后自动清除 ToolTip
            SetTimer(() => ToolTip(), -1000)
        } catch as err {
            ; 进度显示失败，不影响注入流程
            ; 静默处理，不显示错误
        }
    }
}

; ============================================================================
; Hotkey_Handler 类 - 热键处理器
; ============================================================================
class Hotkey_Handler {
    ; 依赖
    clipboardProcessor := ""
    injectionEngine := ""
    
    ; 构造函数
    __New(clipProc, injEngine) {
        ; 保存 Clipboard_Processor 的引用
        this.clipboardProcessor := clipProc
        
        ; 保存 Injection_Engine 的引用
        this.injectionEngine := injEngine
    }
    
    ; 紧急停止热键处理 (Shift + Esc)
    OnShiftEsc() {
        ; 显示强制重载提示
        ToolTip("正在强制重载...")
        
        ; 等待 300ms
        Sleep(300)
        
        ; 重载脚本
        Reload
    }
    
    ; 强力复制热键处理 (Ctrl + Insert)
    OnCtrlInsert() {
        try {
            ; 清空剪贴板
            A_Clipboard := ""
            
            ; 发送 Ctrl+C 复制命令
            SendEvent("^c")
            
            ; 使用 ClipWait 等待剪贴板获取文本
            ; 参数1: 超时时间（秒）
            ; 参数2: 等待类型（1 = 等待任何类型的数据）
            ClipWait(1, 1)
            
            ; 显示"已复制"提示
            ToolTip("已复制")
            
            ; 800ms 后自动清除提示
            SetTimer(() => ToolTip(), -800)
        } catch as err {
            ; 复制操作失败
            ToolTip("复制失败: " err.Message)
            SetTimer(() => ToolTip(), -1500)
        }
    }
    
    ; 强力粘贴热键处理 (Shift + Insert)
    OnShiftInsert() {
        try {
            ; 调用 Clipboard_Processor.GetClipboardText() 获取文本
            clipText := this.clipboardProcessor.GetClipboardText()
            
            ; 如果剪贴板为空，显示 ToolTip "剪贴板为空" 并返回
            if (clipText = "" || Trim(clipText) = "") {
                ToolTip("剪贴板为空")
                ; 1000ms 后自动清除提示
                SetTimer(() => ToolTip(), -1000)
                return
            }
            
            ; 调用 Clipboard_Processor.SanitizeText() 消毒文本
            sanitizedText := this.clipboardProcessor.SanitizeText(clipText)
            
            ; 调用 Injection_Engine.InjectText() 执行注入
            this.injectionEngine.InjectText(sanitizedText)
        } catch as err {
            ; 粘贴操作失败
            ToolTip("粘贴失败: " err.Message)
            SetTimer(() => ToolTip(), -1500)
        }
    }
    
    ; 注册所有热键（带错误处理）
    RegisterHotkeys() {
        try {
            ; 注册紧急停止热键 (Shift + Esc)
            Hotkey("+Esc", (*) => this.OnShiftEsc(), "On")
        } catch as err {
            MsgBox("热键注册失败 (Shift+Esc): " err.Message "`n可能与其他程序冲突", "热键冲突", "Icon!")
        }
        
        try {
            ; 注册强力复制热键 (Ctrl + Insert)
            Hotkey("^Insert", (*) => this.OnCtrlInsert(), "On")
        } catch as err {
            MsgBox("热键注册失败 (Ctrl+Insert): " err.Message "`n可能与其他程序冲突", "热键冲突", "Icon!")
        }
        
        try {
            ; 注册强力粘贴热键 (Shift + Insert)
            Hotkey("+Insert", (*) => this.OnShiftInsert(), "On")
        } catch as err {
            MsgBox("热键注册失败 (Shift+Insert): " err.Message "`n可能与其他程序冲突", "热键冲突", "Icon!")
        }
    }
}

; ============================================================================
; Startup_Manager 类 - 启动管理器
; ============================================================================
class Startup_Manager {
    ; 系统注册表路径常量
    ; 使用 HKCU (HKEY_CURRENT_USER) 不需要管理员权限
    regKey := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    
    ; 注册表键值名称（用于标识本工具）
    regValueName := "YouCanCopyAndPasteV2"
    
    ; 构造函数
    __New() {
        ; 初始化完成
        ; 注册表路径已在类属性中定义
    }
    
    ; 启用开机自启动
    ; 参数: scriptPath - 脚本的绝对路径
    EnableStartup(scriptPath) {
        try {
            ; 使用 RegWrite 将脚本路径写入注册表
            ; 参数说明：
            ; - "REG_SZ": 字符串类型
            ; - this.regKey: 注册表路径
            ; - this.regValueName: 键值名称
            ; - scriptPath: 脚本的绝对路径
            RegWrite(scriptPath, "REG_SZ", this.regKey, this.regValueName)
            return true
        } catch as err {
            ; 写入失败时返回 false
            MsgBox("启用开机自启动失败: " err.Message "`n`n可能原因：`n• 注册表访问权限不足`n• 系统策略限制", "错误", "Icon!")
            return false
        }
    }
    
    ; 禁用开机自启动
    DisableStartup() {
        try {
            ; 使用 RegDelete 从注册表中删除该工具的启动键值
            RegDelete(this.regKey, this.regValueName)
            return true
        } catch as err {
            ; 如果键值不存在，RegDelete 会抛出异常
            ; 这种情况下也视为成功（因为目标已达成：键值不存在）
            ; 但如果是其他错误，则显示错误消息
            if (InStr(err.Message, "找不到") || InStr(err.Message, "not found")) {
                ; 键值不存在，视为成功
                return true
            } else {
                ; 其他错误
                MsgBox("禁用开机自启动失败: " err.Message "`n`n可能原因：`n• 注册表访问权限不足`n• 系统策略限制", "错误", "Icon!")
                return false
            }
        }
    }
    
    ; 检查是否已启用开机自启动
    IsStartupEnabled() {
        try {
            ; 使用 RegRead 检查注册表中是否已存在该键值
            value := RegRead(this.regKey, this.regValueName)
            
            ; 如果能成功读取到值，说明已启用自启动
            return true
        } catch as err {
            ; 如果读取失败（键值不存在），说明未启用自启动
            return false
        }
    }
    
    ; 检查当前是否以管理员权限运行
    IsAdmin() {
        ; 使用 AutoHotkey 内置变量 A_IsAdmin
        ; 返回 true 表示以管理员权限运行，false 表示普通权限
        return A_IsAdmin
    }
    
    ; 请求管理员权限提升
    ; 参数: scriptPath - 脚本的绝对路径（可选，默认使用 A_ScriptFullPath）
    RequestAdminElevation(scriptPath := "") {
        ; 如果已经是管理员权限，无需提权
        if (this.IsAdmin()) {
            MsgBox("当前已以管理员权限运行", "提示", "Iconi")
            return true
        }
        
        ; 如果未提供脚本路径，使用当前脚本的完整路径
        if (scriptPath = "") {
            scriptPath := A_ScriptFullPath
        }
        
        try {
            ; 使用 Run 命令以管理员权限重启脚本
            ; *RunAs 动词会触发 UAC 提示，请求管理员权限
            Run("*RunAs " scriptPath)
            
            ; 提权请求成功，退出当前实例
            ; 新的管理员权限实例将会启动
            ExitApp
            
            return true
        } catch as err {
            ; 提权失败时显示错误消息
            MsgBox("管理员权限提升失败: " err.Message "`n`n可能原因：`n• 用户取消了 UAC 提示`n• 系统策略限制`n• 脚本路径无效", "错误", "Icon!")
            return false
        }
    }
}

; ============================================================================
; UI_Manager 类 - 界面管理器
; ============================================================================
class UI_Manager {
    ; 依赖
    configManager := ""
    startupManager := ""
    
    ; 构造函数
    __New(configMgr, startupMgr) {
        ; 保存 Config_Manager 的引用
        this.configManager := configMgr
        
        ; 保存 Startup_Manager 的引用
        this.startupManager := startupMgr
    }
    
    ; 显示欢迎界面
    ShowWelcomeWindow() {
        try {
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
            在禁止粘贴的编辑器中自由输入代码
            )"
            welcomeGui.Add("Text", "Center w400", descriptionText)
            
            ; 添加分隔线
            welcomeGui.Add("Text", "w400 0x10")  ; 0x10 = SS_SUNKEN (凹陷线条)
            
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
        } catch as err {
            ; 欢迎界面创建失败
            MsgBox("欢迎界面显示失败: " err.Message "`n`n脚本将继续运行", "错误", "Icon!")
        }
    }
    
    ; 欢迎界面 - "进入设置"按钮点击处理
    OnWelcomeSettingsClick(welcomeGui) {
        try {
            ; 关闭欢迎窗口
            welcomeGui.Destroy()
            
            ; 打开设置窗口
            this.ShowSettingsWindow()
        } catch as err {
            ; 处理失败
            MsgBox("打开设置窗口失败: " err.Message, "错误", "Icon!")
        }
    }
    
    ; 欢迎界面 - "开始使用"按钮点击处理
    OnWelcomeStartClick(welcomeGui) {
        try {
            ; 设置 FirstRun=0
            this.configManager.SetFirstRun(0)
            
            ; 保存配置
            this.configManager.SaveConfig()
            
            ; 关闭欢迎窗口
            welcomeGui.Destroy()
        } catch as err {
            ; 处理失败
            MsgBox("保存配置失败: " err.Message "`n`n窗口将关闭，但首次运行标志未更新", "错误", "Icon!")
            welcomeGui.Destroy()
        }
    }
    
    ; 显示设置界面
    ShowSettingsWindow() {
        try {
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
        } catch as err {
            ; 设置界面创建失败
            MsgBox("设置界面显示失败: " err.Message, "错误", "Icon!")
        }
    }
    
    ; 延迟模式切换处理
    OnDelayModeChange(dropdown, baseDelayEdit, varianceEdit) {
        try {
            ; 获取选中的模式
            selectedMode := dropdown.Text
            
            ; 获取预设值
            delayAlgo := Delay_Algorithm(this.configManager)
            presetValues := delayAlgo.GetPresetValues(selectedMode)
            
            ; 更新输入框的值
            baseDelayEdit.Value := presetValues.baseDelay
            varianceEdit.Value := presetValues.variance
        } catch as err {
            ; 模式切换失败，静默处理
            ToolTip("延迟模式切换失败: " err.Message)
            SetTimer(() => ToolTip(), -1500)
        }
    }
    
    ; 请求管理员权限按钮处理
    OnRequestAdminClick() {
        try {
            ; 调用 Startup_Manager 的 RequestAdminElevation 方法
            this.startupManager.RequestAdminElevation()
        } catch as err {
            ; 请求失败
            MsgBox("请求管理员权限失败: " err.Message, "错误", "Icon!")
        }
    }
    
    ; 保存设置按钮处理
    OnSaveSettingsClick(settingsGui, delayModeDropdown, baseDelayEdit, varianceEdit, startupCheckbox) {
        try {
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
                ; 更新托盘提示信息
                global trayController
                trayController.UpdateTrayTooltip()
                
                ; 显示保存成功提示
                ToolTip("设置已保存")
                SetTimer(() => ToolTip(), -1000)
                
                ; 关闭设置窗口
                settingsGui.Destroy()
            } else {
                ; 保存失败（Config_Manager 会显示错误消息）
                ; 不关闭窗口，让用户可以重试
            }
        } catch as err {
            ; 保存设置失败
            MsgBox("保存设置失败: " err.Message, "错误", "Icon!")
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
; Tray_Controller 类 - 托盘控制器
; ============================================================================
class Tray_Controller {
    ; 依赖
    uiManager := ""
    configManager := ""
    
    ; 构造函数
    __New(uiMgr, configMgr) {
        ; 保存 UI_Manager 的引用
        this.uiManager := uiMgr
        
        ; 保存 Config_Manager 的引用
        this.configManager := configMgr
    }
    
    ; 创建托盘图标和菜单
    CreateTrayIcon() {
        try {
            ; 删除默认菜单项
            A_TrayMenu.Delete()
            
            ; 添加菜单项："使用说明"
            A_TrayMenu.Add("使用说明", (*) => this.OnUsageClick())
            
            ; 添加菜单项："设置"
            A_TrayMenu.Add("设置", (*) => this.OnSettingsClick())
            
            ; 添加菜单项："休眠/唤醒"
            A_TrayMenu.Add("休眠/唤醒", (*) => this.OnSuspendClick())
            
            ; 添加菜单项："重载脚本"
            A_TrayMenu.Add("重载脚本", (*) => this.OnReloadClick())
            
            ; 添加分隔线
            A_TrayMenu.Add()
            
            ; 添加菜单项："退出"
            A_TrayMenu.Add("退出", (*) => this.OnExitClick())
            
            ; 显示托盘图标
            A_IconHidden := false
        } catch as err {
            ; 托盘图标创建失败
            MsgBox("托盘图标创建失败: " err.Message "`n`n脚本将继续运行，但无法通过托盘访问", "错误", "Icon!")
        }
    }
    
    ; 使用说明菜单项处理
    OnUsageClick() {
        ; 显示使用说明消息框
        usageText := "
        (
        Force-Copy-And-Paste-least v2.0 使用说明
        
        快捷键：
        • Shift + Esc：紧急停止（重载脚本）
        • Ctrl + Insert：强力复制
        • Shift + Insert：强力粘贴（沙箱穿透）
        
        功能说明：
        本工具通过模拟物理键盘输入，突破在线代码编辑器的粘贴限制。
        
        使用方法：
        1. 复制需要粘贴的代码
        2. 在目标编辑器中定位光标
        3. 按 Shift + Insert 触发注入
        4. 等待注入完成
        
        注意事项：
        • 注入过程中请勿操作键盘和鼠标
        • 如遇问题可按 Shift + Esc 紧急停止
        • 可在设置中调整注入速度
        )"
        
        MsgBox(usageText, "使用说明", "Iconi")
    }
    
    ; 设置菜单项处理
    OnSettingsClick() {
        try {
            ; 调用 UI_Manager.ShowSettingsWindow()
            ; 注意：UI_Manager 将在后续任务中实现
            if (this.uiManager != "") {
                this.uiManager.ShowSettingsWindow()
            } else {
                MsgBox("设置功能尚未实现", "提示", "Iconi")
            }
        } catch as err {
            ; 打开设置失败
            MsgBox("打开设置窗口失败: " err.Message, "错误", "Icon!")
        }
    }
    
    ; 休眠/唤醒菜单项处理
    OnSuspendClick() {
        ; 使用 Suspend 命令切换脚本状态
        Suspend(-1)  ; -1 表示切换状态
        
        ; 显示当前状态
        if (A_IsSuspended) {
            ToolTip("脚本已休眠")
        } else {
            ToolTip("脚本已唤醒")
        }
        
        ; 1 秒后清除提示
        SetTimer(() => ToolTip(), -1000)
    }
    
    ; 重载脚本菜单项处理
    OnReloadClick() {
        ; 调用 Reload 命令重载脚本
        Reload
    }
    
    ; 退出菜单项处理
    OnExitClick() {
        ; 退出脚本
        ExitApp
    }
    
    ; 更新托盘提示信息
    UpdateTrayTooltip() {
        try {
            ; 读取当前延迟模式
            delayMode := this.configManager.GetDelayMode()
            
            ; 获取延迟模式的中文名称
            modeName := ""
            switch delayMode {
                case "Fast":
                    modeName := "快速"
                case "Standard":
                    modeName := "标准"
                case "Conservative":
                    modeName := "保守"
                default:
                    modeName := "标准"
            }
            
            ; 检查管理员权限状态
            adminStatus := A_IsAdmin ? " [管理员]" : ""
            
            ; 构建托盘提示文本
            tooltipText := "Force-Copy-And-Paste-least v2.0`n延迟模式: " modeName adminStatus
            
            ; 更新托盘图标提示
            A_IconTip := tooltipText
        } catch as err {
            ; 更新托盘提示失败，静默处理
            ; 不影响脚本运行
        }
    }
}

; ============================================================================
; 创建模块实例
; ============================================================================

try {
    ; 创建 Delay_Algorithm 实例
    global delayAlgorithm := Delay_Algorithm(configManager)
    
    ; 创建 Clipboard_Processor 实例
    global clipboardProcessor := Clipboard_Processor()
    
    ; 创建 Injection_Engine 实例
    global injectionEngine := Injection_Engine(delayAlgorithm)
    
    ; 创建 Startup_Manager 实例
    global startupManager := Startup_Manager()
    
    ; 创建 UI_Manager 实例
    global uiManager := UI_Manager(configManager, startupManager)
    
    ; 创建 Hotkey_Handler 实例
    global hotkeyHandler := Hotkey_Handler(clipboardProcessor, injectionEngine)
    
    ; 创建 Tray_Controller 实例
    global trayController := Tray_Controller(uiManager, configManager)
} catch as err {
    ; 模块初始化失败
    MsgBox("模块初始化失败: " err.Message "`n`n脚本无法继续运行", "严重错误", "Icon! T10")
    ExitApp
}

; ============================================================================
; 初始化托盘图标
; ============================================================================

try {
    ; 创建托盘图标和菜单
    trayController.CreateTrayIcon()
    
    ; 更新托盘提示信息
    trayController.UpdateTrayTooltip()
} catch as err {
    ; 托盘初始化失败，不影响核心功能
    ; 错误已在 CreateTrayIcon 中处理
}

; ============================================================================
; 首次运行检查
; ============================================================================

try {
    ; 如果是首次运行，显示欢迎界面
    if (configManager.IsFirstRun()) {
        uiManager.ShowWelcomeWindow()
    }
} catch as err {
    ; 欢迎界面显示失败，不影响核心功能
    ; 错误已在 ShowWelcomeWindow 中处理
}

; ============================================================================
; 注册热键
; ============================================================================

try {
    ; 调用 Hotkey_Handler.RegisterHotkeys() 注册热键
    hotkeyHandler.RegisterHotkeys()
} catch as err {
    ; 热键注册失败
    MsgBox("热键注册失败: " err.Message "`n`n脚本将继续运行，但热键可能无法使用", "错误", "Icon!")
}
