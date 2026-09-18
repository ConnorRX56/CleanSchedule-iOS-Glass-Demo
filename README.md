# CleanSchedule · iPhone Glass Demo

用于验证 iPhone 原生 Liquid Glass、交互和免费安装流程的小演示。使用 SwiftUI 系统字体、SF Symbols、GlassEffectContainer 和原生玻璃材质。

最低系统 iOS 26；目标试用设备为 iOS 27。电脑没有 Mac 也可以通过标准 GitHub macOS runner 构建。本仓库不包含 Apple 账号、签名证书、个人课表或 Android 工程。

## 手机上可以做什么

- 点顶部居中的 W 打开选周面板；左右滑 W 切周。
- 下拉 W，玻璃跟手变成三个分离的圆球；上推或点击空白处收回。
- 点中间的 W 或右边日期球，原球连续展开成面板，关闭后回到原处。
- 左球直接打开 iOS 文件选择器。演示仅显示所选 `.xls` 的文件名，不解析或替换课表。
- 背景是固定的示例课程，用于观察透色、折射和背景虚化。完整课表的解析、X/Y 缩放及持久化尚未移植。

控制区位于 App 内、系统灵动岛下方的安全区域，没有修改 iOS 的系统灵动岛。参考目的为交互演示，不宣称与某段视频逐帧相同。

## 免费构建

GitHub Actions 的工作流只手动触发，没有 push 定时构建，没有付费 runner，没有远程签名服务。

公开仓库使用标准 `macos-26` runner。私有仓库默认不运行，必须由账号所有者先核对免费额度及零元支出限制，再明确选择 `private_free_allowance_confirmed`。该选项不是自动查询额度，不能勾选后就假定免费。

输出放在 **draft release**，不使用计量收费的 Actions artifact 缓存/存储；每次构建最多运行 18 分钟。公开源码需要仓库所有者同意，不会为了构建自动切换仓库可见性。

成功构建后输出：

- `CleanSchedule-Glass-Demo-0.1.0-unsigned.ipa`：iPhone ARM64 安装包，需要本地签名。
- 同名 `.json`：包 ID、最低系统、大小和 SHA-256。
- `device-build.log`、`test.log`、`test-summary.json`：编译和功能检查结果。

在 Mac 上也可以执行 `bash tools/build.sh`。脚本生成工程和本地绘制的图标，先编译 iPhone 包，再在已有的 iOS 26+ 模拟器上跑功能测试，不额外下载模拟器运行时。

## 用 Windows 安装

见 [安装说明](INSTALL-WINDOWS.md)。未签名 IPA 不能直接在 iPhone 的“文件”中点开安装，需要使用自己的 Apple 账号在本地签名。

## 验证范围

包含几何、手势方向/阈值、周次边界的单元测试，以及点按选周、横滑切周、下拉展开/日期返回的 UI 逻辑测试。只有实际云端运行结束才算构建和测试通过。

本演示没有声称已经安装到用户的 iOS 27 手机，也没有替用户作视觉或手感验收。未签名包中没有远程调试、应用扩展或后台网络功能。

参考：[Apple Liquid Glass](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)、[GitHub Actions 免费范围](https://docs.github.com/en/billing/concepts/product-billing/github-actions)、[GitHub Releases 限制](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)、[Sideloadly 安装和刷新说明](https://sideloadly.io/faq)。
