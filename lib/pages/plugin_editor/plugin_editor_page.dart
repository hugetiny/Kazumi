import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/plugins/plugins_providers.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';

class PluginEditorPage extends ConsumerStatefulWidget {
  const PluginEditorPage({
    super.key,
    required this.plugin,
  });

  final Plugin plugin;

  @override
  ConsumerState<PluginEditorPage> createState() => _PluginEditorPageState();
}

class _PluginEditorPageState extends ConsumerState<PluginEditorPage> {
  late final PluginsController pluginsController;
  final TextEditingController apiController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController versionController = TextEditingController();
  final TextEditingController userAgentController = TextEditingController();
  final TextEditingController baseURLController = TextEditingController();
  final TextEditingController searchURLController = TextEditingController();
  final TextEditingController searchListController = TextEditingController();
  final TextEditingController searchNameController = TextEditingController();
  final TextEditingController searchResultController = TextEditingController();
  final TextEditingController chapterRoadsController = TextEditingController();
  final TextEditingController chapterResultController = TextEditingController();
  final TextEditingController refererController = TextEditingController();
  bool muliSources = true;
  bool useWebview = true;
  bool useNativePlayer = true;
  bool usePost = false;
  bool useLegacyParser = false;

  @override
  void initState() {
    super.initState();
    pluginsController = ref.read(pluginsControllerProvider.notifier);
    final Plugin plugin = widget.plugin;
    apiController.text = plugin.api;
    typeController.text = plugin.type;
    nameController.text = plugin.name;
    versionController.text = plugin.version;
    userAgentController.text = plugin.userAgent;
    baseURLController.text = plugin.baseUrl;
    searchURLController.text = plugin.searchURL;
    searchListController.text = plugin.searchList;
    searchNameController.text = plugin.searchName;
    searchResultController.text = plugin.searchResult;
    chapterRoadsController.text = plugin.chapterRoads;
    chapterResultController.text = plugin.chapterResult;
    refererController.text = plugin.referer;
    muliSources = plugin.muliSources;
    useWebview = plugin.useWebview;
    useNativePlayer = plugin.useNativePlayer;
    usePost = plugin.usePost;
    useLegacyParser = plugin.useLegacyParser;
  }

  @override
  Widget build(BuildContext context) {
    final Plugin plugin = widget.plugin;
    final editorTexts = context.t.settings.plugins.editor;

    return Scaffold(
      appBar: SysAppBar(
        title: Text(editorTexts.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: (MediaQuery.of(context).size.width > 1000) ? 1000 : null,
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: editorTexts.fields.name,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: versionController,
                  decoration: InputDecoration(
                    labelText: editorTexts.fields.version,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: baseURLController,
                  decoration: InputDecoration(
                    labelText: editorTexts.fields.baseUrl,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchURLController,
                  decoration: InputDecoration(
                    labelText: editorTexts.fields.searchUrl,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchListController,
                  decoration: InputDecoration(
                    labelText: editorTexts.fields.searchList,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchNameController,
                  decoration: InputDecoration(
                    labelText: editorTexts.fields.searchName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchResultController,
                  decoration: InputDecoration(
                    labelText: editorTexts.fields.searchResult,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: chapterRoadsController,
                  decoration: InputDecoration(
                    labelText: editorTexts.fields.chapterRoads,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: chapterResultController,
                  decoration: InputDecoration(
                    labelText: editorTexts.fields.chapterResult,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ExpansionTile(
                  title: Text(editorTexts.advanced.title),
                  children: [
                    SwitchListTile(
                      title: Text(editorTexts.advanced.legacyParser.title),
                      subtitle:
                          Text(editorTexts.advanced.legacyParser.subtitle),
                      value: useLegacyParser,
                      onChanged: (bool value) {
                        setState(() {
                          useLegacyParser = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text(editorTexts.advanced.httpPost.title),
                      subtitle: Text(editorTexts.advanced.httpPost.subtitle),
                      value: usePost,
                      onChanged: (bool value) {
                        setState(() {
                          usePost = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text(editorTexts.advanced.nativePlayer.title),
                      subtitle:
                          Text(editorTexts.advanced.nativePlayer.subtitle),
                      value: useNativePlayer,
                      onChanged: (bool value) {
                        setState(() {
                          useNativePlayer = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: userAgentController,
                      decoration: InputDecoration(
                        labelText: editorTexts.fields.userAgent,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: refererController,
                      decoration: InputDecoration(
                        labelText: editorTexts.fields.referer,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          plugin.api = apiController.text;
          plugin.type = typeController.text;
          plugin.name = nameController.text;
          plugin.version = versionController.text;
          plugin.userAgent = userAgentController.text;
          plugin.baseUrl = baseURLController.text;
          plugin.searchURL = searchURLController.text;
          plugin.searchList = searchListController.text;
          plugin.searchName = searchNameController.text;
          plugin.searchResult = searchResultController.text;
          plugin.chapterRoads = chapterRoadsController.text;
          plugin.chapterResult = chapterResultController.text;
          plugin.muliSources = muliSources;
          plugin.useWebview = useWebview;
          plugin.useNativePlayer = useNativePlayer;
          plugin.usePost = usePost;
          plugin.useLegacyParser = useLegacyParser;
          plugin.referer = refererController.text;
          pluginsController.updatePlugin(plugin);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
