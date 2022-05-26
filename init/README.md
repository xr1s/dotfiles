# 工作区初始化脚本

一站式工作区初始化脚本，懒得每次都手动上去一个一个装软件了。

一直懒得写，因为区分各个发行版太麻烦了，但是最近实在是忍不了了。

就想先实现一个，把目标调小了一点，花了一天把最常用的发行版 Debian 实现了，后续看时间写下别的。

目前在 stretch 和 wsl 的 sid 测试过。

## 前置

1. 需要手动配置代理，因为有循环依赖问题（你需要有代理才能够初始化代理），

   关于这点，远程的时候可以考虑使用 ssh -R 直接将本地的代理端口发送到远端。

   当然 `SetEnv` 需要远程 sshd 配置了 `AcceptEnv` 才会生效，个人不建议加上
``` bash
ssh $user:$host \
  -R $remote_port:$proxy_host:$local_port \
  -o SetEnv=http_proxy=localhost:$remote_port \
  -o SetEnv=https_proxy=localhost:$remote_port
```
2. 需要手动获取 root 权限，因为也有循环依赖问题（你需要有 root 权限才能改 sudoers 文件以获取 root 权限）

## 待办

1. Windows 整体初始化
2. macOS 整体初始化
