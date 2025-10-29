# aria2 下载管理功能

## 概述

Kazumi 现已集成 aria2 下载管理功能，可以通过独立的 aria2 进程进行高效的视频下载管理。

## 功能特性

### 下载管理页面
- **位置**: 我的 → 下载管理
- **功能**:
  - 实时查看下载进度
  - 暂停/继续/删除下载任务
  - 查看下载速度和文件大小
  - 分类显示：下载中、已完成、全部
  - 自动刷新下载状态（2秒间隔）

### 下载设置
- **位置**: 设置 → 下载设置
- **配置项**:
  - aria2 端点地址（默认：http://127.0.0.1:6800/jsonrpc）
  - aria2 密钥配置
  - 请求超时时间（5-120秒）
  - 最大并发下载数
  - 连接测试功能

## 安装 aria2

### Windows
1. 从 [aria2 releases](https://github.com/aria2/aria2/releases) 下载最新版本
2. 解压到任意目录
3. 在命令行中运行：
   ```
   aria2c --enable-rpc --rpc-listen-all
   ```
4. 如需添加密钥保护：
   ```
   aria2c --enable-rpc --rpc-listen-all --rpc-secret=你的密钥
   ```

### macOS
```bash
brew install aria2
aria2c --enable-rpc --rpc-listen-all
```

### Linux
```bash
# Debian/Ubuntu
sudo apt install aria2

# RHEL/CentOS
sudo yum install aria2

# 启动
aria2c --enable-rpc --rpc-listen-all
```

## 使用方法

1. **启动 aria2**
   - 按照上述方式启动 aria2 RPC 服务

2. **配置 Kazumi**
   - 进入"设置 → 下载设置"
   - 确认端点地址正确（默认配置通常无需修改）
   - 如果设置了密钥，填入对应密钥
   - 点击"测试"按钮验证连接

3. **管理下载**
   - 进入"我的 → 下载管理"
   - 查看和管理所有下载任务
   - 使用控制按钮操作任务

## 技术实现

- **架构**: 使用独立 aria2 进程通过 JSON-RPC 通信
- **状态管理**: Riverpod StateNotifier
- **数据持久化**: Hive 数据库
- **自动同步**: 每2秒自动刷新下载状态

## 常见问题

### Q: 为什么选择独立 aria2 而不是 libaria2？
A: 独立 aria2 进程具有以下优势：
- 更稳定和功能完整
- 独立更新维护
- Flutter 集成更简单
- 社区支持更好

### Q: 连接失败怎么办？
A: 检查以下项目：
1. aria2 进程是否正在运行
2. 端点地址是否正确
3. 防火墙是否允许访问
4. 密钥配置是否正确

### Q: 如何设置开机自启？
A: 
- Windows: 创建 bat 脚本并添加到启动文件夹
- macOS/Linux: 创建 systemd 服务或使用 launchd

## 未来计划

- [ ] 支持磁力链接下载
- [ ] 支持 BT 种子下载
- [ ] 下载完成通知
- [ ] 下载队列优先级
- [ ] 自动重试失败任务
