# Windows → iPhone 安装演示

1. 从本次成功构建取得 `CleanSchedule-Glass-Demo-0.1.0-unsigned.ipa`。
2. 从 [Sideloadly 官网](https://sideloadly.io/)下载 Windows 版本。安装所需的 Apple 驱动/iTunes/iCloud 以官网当前说明为准；不要直接删除正在使用的 Apple 软件。
3. 用 USB 连接 iPhone，解锁，并在手机上确认“信任此电脑”。
4. 打开 Sideloadly，将 IPA 拖进去，选择自己的手机。Apple 账号及登录验证只在本机工具或苹果登录界面输入，不发送到聊天或 GitHub。
5. 开始安装。按手机提示，在“设置 → 通用 → VPN 与设备管理”信任开发者；在“设置 → 隐私与安全性”启用开发者模式并按提示重启。
6. 打开手机上的 **课表·Glass**。先点 W 选周，再下拉 W 看三个球，点右球打开日期并关闭，最后点左球确认系统文件选择器能打开。

免费账号的签名通常只有 7 天有效。可以在 Sideloadly 设置自动刷新；电脑需运行它的后台程序，且能通过 USB 或已配置的同网 Wi-Fi 连接手机。到期未刷新会暂时无法打开，需要重新签名。

更新时保持相同 Apple 账号和 bundle ID，覆盖安装，不要先删掉原 App。这个演示使用独立包 ID `app.cleanschedule.glassdemo`。

iOS 27 与当前侧载工具的实际兼容性以设备安装结果为准。安装失败时保留工具的具体错误文字；Apple ID、密码、验证码和签名证书不要放进报错截图或公开 issue。
