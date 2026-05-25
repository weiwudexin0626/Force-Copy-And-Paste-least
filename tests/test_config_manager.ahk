#Requires AutoHotkey v2.0

; 包含主脚本中的 Config_Manager 类
#Include force-copy-and-paste-least-v2.ahk

; 测试 Config_Manager 类
TestConfigManager() {
    testResults := []
    
    ; 测试 1: 创建实例
    try {
        config := Config_Manager(A_ScriptDir)
        testResults.Push("✓ 测试 1: 创建实例成功")
    } catch as err {
        testResults.Push("✗ 测试 1: 创建实例失败 - " err.Message)
        return testResults
    }
    
    ; 测试 2: 创建默认配置
    try {
        config.CreateDefaultConfig()
        if FileExist(A_ScriptDir "\config.ini") {
            testResults.Push("✓ 测试 2: 创建默认配置文件成功")
        } else {
            testResults.Push("✗ 测试 2: 配置文件未创建")
        }
    } catch as err {
        testResults.Push("✗ 测试 2: 创建默认配置失败 - " err.Message)
    }
    
    ; 测试 3: 验证默认值
    if (config.GetDelayMode() = "Standard" 
        && config.GetBaseDelay() = 30 
        && config.GetDelayVariance() = 15 
        && !config.IsStartupEnabled() 
        && config.IsFirstRun()) {
        testResults.Push("✓ 测试 3: 默认值正确")
    } else {
        testResults.Push("✗ 测试 3: 默认值不正确")
    }
    
    ; 测试 4: 设置和获取 DelayMode
    if (config.SetDelayMode("Fast") && config.GetDelayMode() = "Fast") {
        testResults.Push("✓ 测试 4: DelayMode setter/getter 正常")
    } else {
        testResults.Push("✗ 测试 4: DelayMode setter/getter 失败")
    }
    
    ; 测试 5: 设置和获取 BaseDelay
    if (config.SetBaseDelay(50) && config.GetBaseDelay() = 50) {
        testResults.Push("✓ 测试 5: BaseDelay setter/getter 正常")
    } else {
        testResults.Push("✗ 测试 5: BaseDelay setter/getter 失败")
    }
    
    ; 测试 6: 设置和获取 DelayVariance
    if (config.SetDelayVariance(25) && config.GetDelayVariance() = 25) {
        testResults.Push("✓ 测试 6: DelayVariance setter/getter 正常")
    } else {
        testResults.Push("✗ 测试 6: DelayVariance setter/getter 失败")
    }
    
    ; 测试 7: 设置和获取 StartupEnabled
    config.SetStartupEnabled(true)
    if config.IsStartupEnabled() {
        testResults.Push("✓ 测试 7: StartupEnabled setter/getter 正常")
    } else {
        testResults.Push("✗ 测试 7: StartupEnabled setter/getter 失败")
    }
    
    ; 测试 8: 设置和获取 FirstRun
    config.SetFirstRun(false)
    if !config.IsFirstRun() {
        testResults.Push("✓ 测试 8: FirstRun setter/getter 正常")
    } else {
        testResults.Push("✗ 测试 8: FirstRun setter/getter 失败")
    }
    
    ; 测试 9: 保存配置
    if config.SaveConfig() {
        testResults.Push("✓ 测试 9: 保存配置成功")
    } else {
        testResults.Push("✗ 测试 9: 保存配置失败")
    }
    
    ; 测试 10: 加载配置
    try {
        config2 := Config_Manager(A_ScriptDir)
        config2.LoadConfig()
        if (config2.GetDelayMode() = "Fast" 
            && config2.GetBaseDelay() = 50 
            && config2.GetDelayVariance() = 25 
            && config2.IsStartupEnabled() 
            && !config2.IsFirstRun()) {
            testResults.Push("✓ 测试 10: 加载配置成功且值正确")
        } else {
            testResults.Push("✗ 测试 10: 加载配置后值不正确")
        }
    } catch as err {
        testResults.Push("✗ 测试 10: 加载配置失败 - " err.Message)
    }
    
    ; 测试 11: 输入验证 - 无效的 DelayMode
    if !config.SetDelayMode("Invalid") {
        testResults.Push("✓ 测试 11: DelayMode 输入验证正常")
    } else {
        testResults.Push("✗ 测试 11: DelayMode 输入验证失败")
    }
    
    ; 测试 12: 输入验证 - 超出范围的 BaseDelay
    if !config.SetBaseDelay(2000) {
        testResults.Push("✓ 测试 12: BaseDelay 输入验证正常")
    } else {
        testResults.Push("✗ 测试 12: BaseDelay 输入验证失败")
    }
    
    ; 测试 13: 输入验证 - 超出范围的 DelayVariance
    if !config.SetDelayVariance(600) {
        testResults.Push("✓ 测试 13: DelayVariance 输入验证正常")
    } else {
        testResults.Push("✗ 测试 13: DelayVariance 输入验证失败")
    }
    
    ; 测试 14: 配置文件损坏恢复
    try {
        ; 写入损坏的配置
        FileDelete(A_ScriptDir "\config.ini")
        FileAppend("这是损坏的配置文件内容`n[Settings]`nDelayMode=InvalidMode", A_ScriptDir "\config.ini")
        
        config3 := Config_Manager(A_ScriptDir)
        config3.LoadConfig()
        
        ; 验证是否恢复为默认值
        if (config3.GetDelayMode() = "Standard" 
            && config3.GetBaseDelay() = 30 
            && config3.GetDelayVariance() = 15) {
            testResults.Push("✓ 测试 14: 配置文件损坏时自动重建成功")
        } else {
            testResults.Push("✗ 测试 14: 配置文件损坏时未正确重建")
        }
    } catch as err {
        testResults.Push("✗ 测试 14: 配置文件损坏恢复测试失败 - " err.Message)
    }
    
    ; 清理测试文件
    try {
        FileDelete(A_ScriptDir "\config.ini")
    }
    
    return testResults
}

; 运行测试
results := TestConfigManager()

; 显示测试结果
output := "Config_Manager 测试结果:`n`n"
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

MsgBox(output, "测试结果", "Icon" (failCount = 0 ? "i" : "!"))
ExitApp
