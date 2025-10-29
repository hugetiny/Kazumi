import 'dart:io';
import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/utils/aria2_client.dart';
import 'package:kazumi/utils/aria2_process_manager.dart';
import 'package:kazumi/utils/storage.dart';

class DownloadSettingsPage extends StatefulWidget {
  const DownloadSettingsPage({super.key});

  @override
  State<DownloadSettingsPage> createState() => _DownloadSettingsPageState();
}

class _DownloadSettingsPageState extends State<DownloadSettingsPage> {
  final TextEditingController _endpointController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  final TextEditingController _timeoutController = TextEditingController();
  final TextEditingController _maxConcurrentController =
      TextEditingController();

  bool _isTestingConnection = false;
  bool _isRestartingAria2 = false;
  String? _connectionStatus;
  String? _aria2Status;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkAria2Status();
  }

  void _checkAria2Status() {
    if (Platform.isIOS) {
      setState(() {
        _aria2Status = 'iOS 不支持自动启动 aria2';
      });
    } else {
      final isRunning = Aria2ProcessManager().isRunning;
      setState(() {
        _aria2Status = isRunning ? 'aria2 运行中' : 'aria2 未运行';
      });
    }
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _secretController.dispose();
    _timeoutController.dispose();
    _maxConcurrentController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final setting = GStorage.setting;
    _endpointController.text = setting.get(
      SettingBoxKey.aria2Endpoint,
      defaultValue: 'http://127.0.0.1:6800/jsonrpc',
    ) as String;
    _secretController.text =
        setting.get(SettingBoxKey.aria2Secret, defaultValue: '') as String;
    _timeoutController.text =
        (setting.get(SettingBoxKey.aria2TimeoutSeconds, defaultValue: 15)
                as int)
            .toString();
    _maxConcurrentController.text = (setting.get(
      SettingBoxKey.aria2MaxConcurrentDownloads,
      defaultValue: 2,
    ) as int)
        .toString();
  }

  Future<void> _saveSettings() async {
    final setting = GStorage.setting;

    final endpoint = _endpointController.text.trim();
    if (endpoint.isEmpty) {
      KazumiDialog.showToast(message: '端点地址不能为空');
      return;
    }

    try {
      Uri.parse(endpoint);
    } catch (e) {
      KazumiDialog.showToast(message: '端点地址格式不正确');
      return;
    }

    final timeoutSeconds = int.tryParse(_timeoutController.text.trim());
    if (timeoutSeconds == null || timeoutSeconds < 5 || timeoutSeconds > 120) {
      KazumiDialog.showToast(message: '超时时间必须在5-120秒之间');
      return;
    }

    final maxConcurrent = int.tryParse(_maxConcurrentController.text.trim());
    if (maxConcurrent == null || maxConcurrent < 1) {
      KazumiDialog.showToast(message: '最大并发下载数必须大于0');
      return;
    }

    await setting.put(SettingBoxKey.aria2Endpoint, endpoint);
    await setting.put(SettingBoxKey.aria2Secret, _secretController.text.trim());
    await setting.put(SettingBoxKey.aria2TimeoutSeconds, timeoutSeconds);
    await setting.put(
        SettingBoxKey.aria2MaxConcurrentDownloads, maxConcurrent);

    if (mounted) {
      KazumiDialog.showToast(message: '设置已保存');
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = null;
    });

    try {
      final endpoint = Uri.parse(_endpointController.text.trim());
      final secret = _secretController.text.trim();
      final timeoutSeconds = int.tryParse(_timeoutController.text.trim()) ?? 15;

      final client = Aria2Client(
        endpoint: endpoint,
        secret: secret.isEmpty ? null : secret,
        timeout: Duration(seconds: timeoutSeconds),
      );

      // Test connection by getting version
      await client.tellActive();

      setState(() {
        _connectionStatus = '连接成功';
        _isTestingConnection = false;
      });
    } catch (e) {
      setState(() {
        _connectionStatus = '连接失败: $e';
        _isTestingConnection = false;
      });
    }
  }

  Future<void> _restartAria2() async {
    if (Platform.isIOS) {
      KazumiDialog.showToast(message: 'iOS 不支持自动启动 aria2');
      return;
    }

    setState(() {
      _isRestartingAria2 = true;
      _aria2Status = '正在重启 aria2...';
    });

    try {
      final success = await Aria2ProcessManager().restart();
      setState(() {
        _isRestartingAria2 = false;
        _aria2Status = success ? 'aria2 重启成功' : 'aria2 重启失败';
      });
      if (success) {
        KazumiDialog.showToast(message: 'aria2 重启成功');
      } else {
        KazumiDialog.showToast(message: 'aria2 重启失败，请检查是否已安装 aria2');
      }
    } catch (e) {
      setState(() {
        _isRestartingAria2 = false;
        _aria2Status = 'aria2 重启失败';
      });
      KazumiDialog.showToast(message: 'aria2 重启失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SysAppBar(
        title: const Text('下载设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: '保存',
          ),
        ],
      ),
      body: SettingsList(
        maxWidth: 1000,
        sections: [
          SettingsSection(
            title: const Text('aria2 设置'),
            tiles: [
              SettingsTile(
                title: const Text('端点地址'),
                description: const Text('aria2 JSON-RPC 端点'),
                leading: const Icon(Icons.link),
                trailing: SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _endpointController,
                    decoration: const InputDecoration(
                      hintText: 'http://127.0.0.1:6800/jsonrpc',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              SettingsTile(
                title: const Text('密钥 (Secret)'),
                description: const Text('aria2 RPC 密钥，留空表示无密钥'),
                leading: const Icon(Icons.vpn_key),
                trailing: SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _secretController,
                    decoration: const InputDecoration(
                      hintText: '可选',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    obscureText: true,
                  ),
                ),
              ),
              SettingsTile(
                title: const Text('超时时间 (秒)'),
                description: const Text('请求超时时间，范围 5-120 秒'),
                leading: const Icon(Icons.timer),
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _timeoutController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              SettingsTile(
                title: const Text('最大并发下载数'),
                description: const Text('同时进行的最大下载任务数'),
                leading: const Icon(Icons.speed),
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _maxConcurrentController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              SettingsTile(
                title: const Text('测试连接'),
                description: _connectionStatus != null
                    ? Text(
                        _connectionStatus!,
                        style: TextStyle(
                          color: _connectionStatus!.contains('成功')
                              ? Colors.green
                              : Colors.red,
                        ),
                      )
                    : const Text('测试 aria2 连接是否正常'),
                leading: const Icon(Icons.network_check),
                trailing: _isTestingConnection
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : ElevatedButton(
                        onPressed: _testConnection,
                        child: const Text('测试'),
                      ),
              ),
            ],
          ),
          if (!Platform.isIOS)
            SettingsSection(
              title: const Text('进程管理'),
              tiles: [
                SettingsTile(
                  title: const Text('aria2 状态'),
                  description: _aria2Status != null
                      ? Text(
                          _aria2Status!,
                          style: TextStyle(
                            color: _aria2Status!.contains('运行中') || _aria2Status!.contains('成功')
                                ? Colors.green
                                : Colors.orange,
                          ),
                        )
                      : const Text('检查 aria2 运行状态'),
                  leading: const Icon(Icons.info_outline),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _checkAria2Status,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('检查'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isRestartingAria2 ? null : _restartAria2,
                        icon: _isRestartingAria2
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.restart_alt, size: 16),
                        label: const Text('重启'),
                      ),
                    ],
                  ),
                ),
                SettingsTile(
                  title: const Text('自动启动'),
                  description: const Text(
                    'Kazumi 会在启动时自动运行 aria2 进程\n'
                    '退出应用时会自动停止 aria2 进程',
                  ),
                  leading: const Icon(Icons.play_circle_outline),
                ),
              ],
            ),
          SettingsSection(
            title: const Text('使用说明'),
            tiles: [
              SettingsTile(
                title: const Text('如何安装 aria2'),
                description: const Text(
                  'aria2 是一个轻量级的多协议下载工具。\n\n'
                  'Windows: 从 https://github.com/aria2/aria2/releases 下载并解压到系统 PATH\n'
                  'macOS: brew install aria2\n'
                  'Linux: sudo apt install aria2 或 sudo yum install aria2\n'
                  'Android: 通过 Termux 安装\n\n'
                  '注意：Kazumi 会自动启动和停止 aria2，无需手动运行',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
