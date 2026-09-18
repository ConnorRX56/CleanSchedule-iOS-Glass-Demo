# 0.1.0 · build 4

已生成 iPhone ARM64 演示包，尚未在用户的 iOS 27 手机安装。

- 文件：`CleanSchedule-Glass-Demo-0.1.0-unsigned.ipa`
- 大小：849,208 字节
- 包 ID：`app.cleanschedule.glassdemo`
- 最低系统：iOS 26.0
- 状态：未签名，需要用户在本机用自己的 Apple 账号签名后安装
- SHA-256：`3ff7ae2d5f81b566778d30839707d7e8fe1a4e6e43b4df987303fd8535c435c6`
- 构建代码提交：`51d6c9de905746d443a96a0003556bf536b392fc`

[完整构建记录](https://github.com/ConnorRX56/CleanSchedule-iOS-Glass-Demo/actions/runs/35333601406)

## 已通过的检查

1. iPhone Release 构建成功。取回安装包后核对 SHA-256、ZIP 完整性、ARM64 可执行文件、iPhoneOS 平台标记与包 ID。
2. 6 项运动/几何单元测试通过。
3. 3 项实际模拟器操作测试通过：点 W 选周并返回；横滑切周且不误开面板；下拉展开后打开原生日历，点击“关闭”，确认日历消失且日期球恢复为可点击的 52pt 小球。

测试环境为 iPhone 17 Pro Max 模拟器、iOS 26.5。9 项通过、0 失败、0 跳过。没有以此声称 iOS 27 真机已经验证，也没有作截图或动画手感验收。

## 免费构建方式

使用经用户同意公开的演示仓库和标准 `macos-26` runner。没有启用付费 runner、私有仓库构建或 Actions artifact 上传；输出保存在发布草稿中。

## 还需用户设备完成

连接 iPhone 并信任电脑，在 Windows 本机签名安装，确认 iOS 27 与当前安装工具的兼容性及实际动画手感。演示使用示例课程；所选 `.xls` 只显示文件名。
