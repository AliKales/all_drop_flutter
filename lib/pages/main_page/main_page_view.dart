// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:all_drop/common_libs.dart';
import 'package:all_drop/core/d_dio.dart';
import 'package:all_drop/core/firebase/f_cloud_db.dart';
import 'package:all_drop/core/firebase/f_storage.dart';
import 'package:all_drop/core/models/m_file.dart';
import 'package:all_drop/core/utils.dart';
import 'package:all_drop/router.dart';
import 'package:all_drop/settings.dart';
import 'package:all_drop/widgets/simple_buttons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uikit/uikit.dart';

import '../../core/firebase/f_auth.dart';

part '_mixin.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> with _Mixin{
  MFile? _file;

  bool _isLoading = true;

  String? _progress;

  bool _checkUpload = false;

  final RegExp _numberBetweenBrackets = RegExp(r'^.*?\((\d+)\).*$');

  int _totalSize = 0;
  int _sizeUploaded = 0;
  final ValueNotifier<String> _sizeText = ValueNotifier<String>("");

  @override
  void initState() {
    super.initState();
    context.afterBuild((p0) {
      _listenSizes();
      _loadFile();
    });
  }

  void _logOut() async {
    await FAuth.logOut();
    context.go(PagePaths.auth);
  }

  void _listenSizes() {
    FCloudDb.listenSizes().listen((event) {
      if (event.exists) {
        _totalSize = event.data()?['totalSize'] ?? 0;
        _sizeUploaded = event.data()?['sizeUploaded'] ?? 0;

        _sizeText.value = "${_sizeUploaded.byte}/${_totalSize.byte}";
      }
    });
  }

  void _loadFile() async {
    setState(() {
      _isLoading = true;
    });
    _file = await FCloudDb.getFile();
    _isLoading = false;
    _checkUpload = false;
    setState(() {});
  }

  Future<String> _setFileName(String fileName, String fileType) async {
    String fullName = "${Settings.pathToDownloadFile}/$fileName.$fileType";

    if (!await Utils.isFileExists(fullName)) return fullName;

    bool isContinue = true;

    int count = 0;

    while (isContinue) {
      count = count + 1;

      fullName = "${Settings.pathToDownloadFile}/$fileName($count).$fileType";

      bool result = await Utils.isFileExists(fullName);

      if (!result) {
        isContinue = false;
      }
    }

    return fullName;
  }

  void _download() async {
    String fullName =
        await _setFileName(_file!.fileName ?? "file", _file!.fileType!);

    DDio.download(
      context,
      _file!.downloadUrl!,
      fullName,
      onProgress: (p0, p1) {
        _progress = "$p0/$p1";
        if (p0 == p1) {
          _progress = null;

          _doneDownload();
        }
        setState(() {});
      },
    );
  }

  void _doneDownload() {
    CustomDialog.showMyDialog(
        context: context,
        title: "Successful",
        text: "Download successful!",
        actions: [
          const SimpleButton(title: "OK"),
        ]);
  }

  void _upload() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    var imageFromGallery = await picker.pickImage(source: ImageSource.gallery);

    if (imageFromGallery == null) return;

    CustomProgressIndicator().showProgressIndicator(context);

    String type = imageFromGallery.path.split(".").last;

    File file = File(imageFromGallery.path);

    int size = await file.length();

    if ((_sizeUploaded + size) > _totalSize) {
      context.back();

      CustomDialog.showMyDialog(
        context: context,
        title: "Error",
        text:
            "You will be out of your total size so you cant upload this file!",
      );

      return;
    }

    context.back();

    if (_file != null) await FStorage.deleteLastFile(_file!.fileType!);

    FStorage.uploadFile(
      file,
      type,
      (p0) {
        setState(() {
          _progress = p0;
        });
      },
      (downloadUrl) async {
        if (_checkUpload) return;

        _checkUpload = true;

        MFile mFile = MFile(
          downloadUrl: downloadUrl,
          fileName: "file",
          fileType: type,
          fileSize: size,
        );

        await FCloudDb.setFileInfo(mFile);

        await CustomDialog.showMyDialog(
            context: context,
            title: "Upload",
            text: "Upload successful!",
            actions: [const SimpleButton(title: "OK")]);

        _loadFile();
      },
      () {
        _isLoading = false;
        _checkUpload = false;
        setState(() {});
        CustomSnackbar.showSnackBar(context: context, text: "Error!");
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
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: _sizeText,
              builder: (context, value, child) {
                return Text(value);
              },
            ),
            TextButton(onPressed: upgrade, child: Text("Upgrade")),
            const Spacer(),
            Text("File Name: ${_file?.fileName}"),
            Text("File Type: ${_file?.fileType}"),
            Text("File Size: ${_file?.fileSize}"),
            Text("File Upload Date: ${_file?.uploadDate}"),
            _getButton(),
            const Divider(),
            _refreshButton(),
            context.sizedBox(height: 0.03),
            FilledButton(onPressed: _upload, child: const Text("Upload"))
                .toEmpty(_progress != null),
            const Spacer(),
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
      actions: [
        IconButton(
          onPressed: _logOut,
          color: Colors.red,
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}
