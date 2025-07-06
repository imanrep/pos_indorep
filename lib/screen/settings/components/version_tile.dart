import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:google_fonts/google_fonts.dart';
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
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Download")),
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
      print('downloading from: $url');
      final dio = Dio();
      await dio.download(
        options: Options(
          headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        ),
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

      var flutterAppInstaller = FlutterAppInstaller();

      await flutterAppInstaller.installApk(filePath: filePath);
    } catch (e) {
      setState(() => isDownloading = false);
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MainProvider>();
    var mainProvider = Provider.of<MainProvider>(context, listen: false);

    return ListTile(
      leading: Icon(
        provider.isUpdateAvailable
            ? Icons.system_update_alt_rounded
            : Icons.info_outline_rounded,
        color: provider.isUpdateAvailable ? Colors.orange : null,
      ),
      title: Text('Version ${mainProvider.appVersion}'),
      subtitle: isDownloading
          ? LinearProgressIndicator(value: downloadProgress)
          : Text(
              provider.isUpdateAvailable
                  ? 'Update available: ${provider.latestVersion}'
                  : provider.appVersion,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
      onTap: provider.isUpdateAvailable && provider.updateUrl != null
          ? () =>
              _promptAndDownload(provider.updateUrl!, provider.latestVersion)
          : null,
    );
  }
}
