# Synology SPK Template

一个**通用**的 Synology DSM 7 套件模板，不绑定具体项目。包含：

- 可复制的最小 `skeleton/`
- 通用开发规范：[docs/SPK-DEV-GUIDE.md](docs/SPK-DEV-GUIDE.md)
- 安装提示 / 卸载数据选择向导模板
- `package` 权限 + SimplePermissionManager 提权说明
- 套件显示名：`displayname` / `displayname_enu` / `displayname_chs` 三处同时配置
- 版本号规范（未发布 0.0.1 → 首版 1.0.0）
- Git / GitHub CLI 推送与 Release 流程

## 快速开始

```bash
cp -a skeleton my-spk
cd my-spk
# 1. 修改 build.conf
# 2. 把你的程序放到 pkg/ 下（bin/、ui/、var/ 等）
# 3. 按需修改 spk/scripts/start-stop-status
./build.sh
```

产物：

```
dist/<PKG_NAME>_<ARCH>-dsm7_<VERSION>.spk
```

当前骨架会启动一个占位的 `hello-daemon.sh`（`sleep` 循环），用于验证安装、启动、停止、卸载流程；替换成你的服务即可。

## 目录

```
synology-spk-template/
├── README.md
├── LICENSE
├── docs/
│   └── SPK-DEV-GUIDE.md          # 通用规范（重点看这个）
└── skeleton/
    ├── build.conf                # 包名、版本、显示名等
    ├── build.sh                  # 一键打包
    ├── pkg/                      # package.tgz 内容
    │   ├── bin/hello-daemon.sh
    │   └── var/config.json
    └── spk/
        ├── INFO.template
        ├── conf/privilege
        ├── scripts/              # 安装/升级/启停钩子
        └── WIZARD_UIFILES/       # 安装提示 + 卸载数据选择
```

## 版本号

- 未正式发布：`0.0.1`、`0.0.2`……
- 首次正式发布：`1.0.0`
- 之后：修复 `1.0.1`、功能 `1.1.0`、破坏性 `2.0.0`
- 不使用 `1.0.0-0001` 这类构建后缀
- DSM 不允许降级，`0.0.x` 只用于全新安装或测试机

## 安装/卸载提示

- 安装时通过 `install_uifile` 提示到 SimplePermissionManager 授权，并说明未授权的降级影响
- 卸载时通过 `uninstall_uifile` 选择「保留（默认）/ 删除」数据
- 向导只在套件中心图形界面显示；CLI 安装/卸载不弹

详见：[docs/SPK-DEV-GUIDE.md](docs/SPK-DEV-GUIDE.md)

## 构建依赖

`bash`、`tar`、`gzip`、`md5sum`、`python3`。无需 Synology SDK。

## License

[MIT](LICENSE)
