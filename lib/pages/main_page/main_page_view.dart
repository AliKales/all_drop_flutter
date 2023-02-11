import 'package:all_drop/common_libs.dart';
import 'package:all_drop/core/d_dio.dart';
import 'package:all_drop/core/firebase/f_cloud_db.dart';
import 'package:all_drop/core/models/m_file.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  MFile? _file;

  bool _isLoading = true;

  String? _progress;

  @override
  void initState() {
    super.initState();
    context.afterBuild((p0) => _loadFile());
  }

  void _loadFile() async {
    setState(() {
      _isLoading = true;
    });
    _file = await FCloudDb.getFile();
    _isLoading = false;
    setState(() {});
  }

  void _download() {
    DDio.download(
      _file!.downloadUrl!,
      "${_file!.fileName}.${_file!.fileType!}",
      onProgress: (p0, p1) {
        _progress = "$p0/$p1";
        if (p0 == p1) {
          _progress = null;
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("File Name: ${_file!.fileName}"),
            Text("File Type: ${_file!.fileType}"),
            Text("File Size: ${_file!.fileSize}"),
            Text("File Upload Date: ${_file!.uploadDate}"),
            _getButton(),
            const Divider(),
            _refreshButton(),
          ],
        ),
      ),
    );
  }

  Widget _getButton() {
    if (_progress != null) return Text(_progress!);
    if (_isLoading) return const CircularProgressIndicator.adaptive();
    if (_file == null) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(onPressed: _download, child: const Text("Download"));
  }

  IconButton _refreshButton() =>
      IconButton(onPressed: _loadFile, icon: const Icon(Icons.refresh));

  AppBar _appBar() {
    return AppBar(
      title: const Text("AllDrop"),
    );
  }
}
