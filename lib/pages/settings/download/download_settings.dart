import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/utils/aria2_client.dart';
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
  String? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
          SettingsSection(
            title: const Text('使用说明'),
            tiles: [
              SettingsTile(
                title: const Text('如何安装 aria2'),
                description: const Text(
                  'aria2 是一个轻量级的多协议下载工具。\n\n'
                  'Windows: 从 https://github.com/aria2/aria2/releases 下载并解压\n'
                  'macOS: brew install aria2\n'
                  'Linux: sudo apt install aria2 或 sudo yum install aria2\n\n'
                  '启动命令: aria2c --enable-rpc --rpc-listen-all\n'
                  '若需密钥: 添加 --rpc-secret=你的密钥',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
