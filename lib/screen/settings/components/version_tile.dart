import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

class VersionTile extends StatefulWidget {
  @override
  _VersionTileState createState() => _VersionTileState();
}

class _VersionTileState extends State<VersionTile> {
  double downloadProgress = 0.0;
  bool isDownloading = false;

  Future<void> _promptAndDownload(String url, String version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Update Available"),
        content: Text("Install version $version?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Download")),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isDownloading = true;
      downloadProgress = 0;
    });

    try {
      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/INDOREP-POS-v$version.apk';

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
      );

      setState(() => isDownloading = false);

      await InstallPlugin.installApk(filePath,); // update this to your package name
    } catch (e) {
      setState(() => isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MainProvider>();

    return ListTile(
      leading: Icon(
        provider.isUpdateAvailable
            ? Icons.system_update_alt_rounded
            : Icons.info_outline_rounded,
        color: provider.isUpdateAvailable ? Colors.orange : null,
      ),
      title: Text('Version'),
      subtitle: isDownloading
          ? LinearProgressIndicator(value: downloadProgress)
          : Text(
              provider.isUpdateAvailable
                  ? 'Update available: ${provider.latestVersion}'
                  : provider.appVersion,
            ),
      onTap: provider.isUpdateAvailable && provider.updateUrl != null
          ? () => _promptAndDownload(provider.updateUrl!, provider.latestVersion)
          : null,
    );
  }
}
