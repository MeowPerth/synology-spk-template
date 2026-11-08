# 最小 SPK 骨架

1. 修改 `build.conf`
2. 把程序放进 `pkg/`（会打进 `package.tgz`，安装到 `SYNOPKG_PKGDEST`）
3. 修改 `spk/scripts/start-stop-status` 启停你的服务
4. 需要桌面 UI 时：
   - 在 `spk/INFO.template` 增加 `dsmuidir="ui"` 和 `dsmappname="<Vendor>.<Pkg>.AppInstance"`
   - 在 `pkg/ui/` 放 `index.html`、`config`、`dsm-wrapper.js`
5. 按需修改 `spk/scripts/` 与 `spk/WIZARD_UIFILES/` 文案
6. `./build.sh`

> `pkg/bin/hello-daemon.sh` 只是占位，记得替换。
