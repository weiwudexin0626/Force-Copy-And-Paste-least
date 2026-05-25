# Force-Copy-And-Paste-least

AutoHotkey v2.0 脚本，用于绕过网页的复制粘贴限制，通过模拟键盘打字的方式将剪贴板内容逐字符输入。

![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0-green.svg)

## 包含两个脚本

| 文件 | 说明 |
|------|------|
| `force-copy-and-paste-least.ahk` | 轻量版，函数式风格，代码简洁，约 420 行 |
| `force-copy-and-paste-least-v2.ahk` | OOP 版，类式结构，功能更丰富，约 1100 行 |

## 功能对比

| 功能 | 轻量版 | OOP 版 |
|------|:---:|:---:|
| 强制复制（绕过网页限制） | `Ctrl+Shift+C` | `Ctrl+Insert` |
| 模拟打字粘贴 | `Ctrl+Shift+V` | `Shift+Insert` |
| 紧急停止 | `Esc` | `Shift+Esc` |
| 文本净化 | 去首尾空白、合并空行 | 去 `\r`、Tab 转空格、NBSP 转空格、剔除零宽字符 |
| 粘贴方式 | `SendText` 整体输出 | `SendEvent {Text}` 逐行注入 |
| 延迟模式 | 固定 / 随机 | Fast / Standard / Conservative |
| GUI 设置面板 | 有 | 有 |
| 开机自启 | 有 | 有 |
| 托盘菜单 | 设置、休眠/唤醒、退出 | 设置、帮助、退出 |
| 首次运行欢迎窗口 | 无 | 有 |
| 注入进度显示 | 无 | 有 |

## 使用方式

1. 安装 [AutoHotkey v2.0](https://www.autohotkey.com/)
2. 双击 `.ahk` 文件运行
3. 在受限网页中选中文本，按对应快捷键复制/粘贴
4. 右键系统托盘图标可打开设置、切换休眠或退出

## 配置（轻量版）

通过 GUI 设置窗口配置，保存至 `config.ini`：

- **延迟模式**：固定延迟（`SetKeyDelay`）或随机延迟（逐字符随机间隔）
- **基础延迟**：默认 15ms
- **最大波动延迟**：默认 50ms（仅随机模式生效）
- **开机自启**：在启动文件夹创建快捷方式

## 配置（OOP 版）

三种预设延迟模式：

| 模式 | 基础延迟 | 波动范围 |
|------|:---:|:---:|
| Fast | 10ms | 5ms |
| Standard | 30ms | 15ms |
| Conservative | 50ms | 25ms |

## 运行环境

- Windows
- [AutoHotkey v2.0](https://www.autohotkey.com/)
- 图标文件 `图标.ico` 需与脚本放在同一目录下

## 免责声明

1. **仅供学习与提效**：本工具的设计初衷是为了方便正当的学习与日常工作，提升在各类受限环境中的文本搬运效率。
2. **禁止违规使用**：严禁将本工具用于任何形式的违规作弊行为（如在线考试、竞赛答题等）或违反目标平台服务条款的操作。
3. **后果自负**：使用者因使用本工具引发的任何账号封禁、成绩取消或法律纠纷，均与本工具开发者无关。下载并使用本工具即视为您完全知晓并同意本声明。
