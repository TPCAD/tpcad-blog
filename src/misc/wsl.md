# WSL

WSL 必须运行在 Windows 10 版本 2004 及更高版本（内部版本 19401 及更高版本）或 Windows 11。

## 安装 WSL

若没有安装过 WSL 可以执行以下命令安装 WSL 及默认发行版（Ubuntu）。使用该命令安装的 WSL 是支持 systemd 的 WSL2。

```bash
wsl --install
```

## 常用命令

```bash
# 查看 WSL 版本
# wsl --version
wsl -v

# 列出已安装的 Linux 发行版
# wsl --list
wsl -l

# 列出已安装的 Linux 发行版的详细信息
# wsl --list --verbose
wsl -l -v

# 列出可下载的 Linux 发行版
# wsl --list --online
wsl -l -o

# 安装默认 Linux 发行版
wsl --install

# 安装指定的 Linux 发行版
wsl --install <distro_name>

# 导出已安装的 Linux 发行版为 tar 文件
wsl --export <distro_name> <tar_file_path>
# wsl --export Ubunt D:\WSL\Ubuntu.tar

# 从 tar 文件导入 Linux 发行版
wsl --import <distro_name> <tar_file_path> <store_path>

# 关闭 WSL
wsl --shutdown
```

## 使用自定义内核

### 编译内核

WSL 使用的内核是 Microsoft 的 [WSL2-Linux-Kernel](https://github.com/microsoft/WSL2-Linux-Kernel)，编译内核需要一个 Linux 环境。

下面以 WSL2 下的 Ubuntu 为例编译 WSL2-Linux-Kernel 6.18 内核。

安装构建依赖。

```bash
sudo apt install build-essential flex bison dwarves libssl-dev libelf-dev cpio qemu-utils
# TUI 配置内核
sudo apt libncurses-dev
```

WSL2 的内核需要使用 Microsoft 提供的内核配置文件进行编译。执行以下命令以 TUI 界面配置指定内核配置文件。修改配置后选择「save」将修改写入原配置文件或新文件。

```bash
make menuconfig KCONFIG_CONFIG=Microsoft/config-wsl
```

以指定配置编译内核。

```bash
make KCONFIG_CONFIG=Microsoft/config-wsl -j$(nproc)
```

### 使用内核

在用户目录`$USERPROFILE/.wslconfig`中添加以下内容。

```toml
[wsl2]
kernel=path_to_custom_kernel
# kernel=C:\\bzImage
```

重启 WSL。

## 清理磁盘

删除 WSL2 磁盘镜像中的文件并不会释放磁盘镜像在 Windows 宿主机中占用的磁盘。使用 diskpart 工具可以释放这些占用的磁盘空间。

```bash
# 执行 diskpart 进入交互式环境
diskpart

# 选择磁盘镜像
select vdisk file=C:\Ubuntu\ext4.vhdx
# 进入磁盘镜像
attach vdisk readonly
# 压缩磁盘镜像
compact vdisk
# 离开磁盘镜像
detach vdisk
# 退出 diskpart
exit
```

## 疑难杂症

### Windows 主机无法通过 localhost 访问 WSL 网络应用

[关闭「快速启动」（存疑）或禁用 IPv6](https://stackoverflow.com/questions/69926941/localhost-refused-to-connect-on-wsl2-when-accessed-via-https-localhost8000-b)。

```toml
[wsl]
# 禁用 IPv6
kernelCommandLine=ipv6.disable=1
```
