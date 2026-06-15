自行打包的 [frp](https://github.com/fatedier/frp)，包括 `frps` 和 `frpc`，适用于基于 Debian 的发行版。

Self-packaged [frp](https://github.com/fatedier/frp), include `frps` 和 `frpc`, suitable for Debian-based distro.


## Usage/用法

### 直接下载 .deb 文件

直接从 [Releases](https://github.com/wcbing-apt-repo/frp-debs/releases) 下载 .deb 文件。

### 添加 apt 仓库

```sh
echo "Types: deb
URIs: https://github.com/wcbing-apt-repo/frp-debs/releases/latest/download/
Suites: ./
Trusted: yes" | sudo tee /etc/apt/sources.list.d/frp.sources
sudo apt update

# install frps
sudo apt install frps
# install frpc
sudo apt install frpc
```

## 配置文件

配置文件在升级或安装时会被覆盖，请注意备份。

> 尤其是 frpc

### frps

frps 有 Systemd 服务，安装后默认启动并设置开机自启。

其配置文件在 `/etc/frp/frps.toml`，修改文件后请重启 Systemd 服务。

### frpc

为保证安全并未设置 Systemd 服务，有需要请自行编写。

默认配置文件在 `/etc/frp/frpc.toml`。

---

更多内容请查看[官网](https://gofrp.org/zh-cn/)。
