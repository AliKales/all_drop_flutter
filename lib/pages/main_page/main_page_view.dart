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
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:uikit/uikit.dart';

import '../../core/firebase/f_auth.dart';

part '_mixin.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> with _Mixin {
  MFile? _file;

  bool _isLoading = true;

  String? _progress;

  bool _checkUpload = false;

  final RegExp _numberBetweenBrackets = RegExp(r'^.*?\((\d+)\).*$');

  int _max = 0;
  int _sizeUploaded = 0;
  final ValueNotifier<String> _sizeText = ValueNotifier<String>("");


  @override
  void initState() {
    super.initState();
    context.afterBuild((p0) {
      _init();
    });
  }

  void _logOut() async {
    await FAuth.logOut();
    context.go(PagePaths.auth);
  }

  void _listenSizes() {
    FCloudDb.listenSizes().listen((event) {
      if (event.exists) {
        int plusSize = event.data()?['plusSize'] ?? 0;
        _sizeUploaded = event.data()?['sizeUploaded'] ?? 0;

        _max = Settings.settings!.minByte! + plusSize;

        _sizeText.value = "${_sizeUploaded.byte}/${_max.byte}";
      }
    });
  }

  void _listenFile() {
    FCloudDb.listenFile().listen((event) {
      if (event.exists) {
        _file = MFile.fromJson(event.data() as Map<String, dynamic>);
        setState(() {});
      }
    });
  }

  void _init() async {
    setState(() {
      _isLoading = true;
    });
    await FCloudDb.getSettings();
    _isLoading = false;
    _checkUpload = false;
    setState(() {});
    _listenSizes();
    _listenFile();
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
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    CustomProgressIndicator().showProgressIndicator(context);

    PlatformFile platformFile = result.files.single;

    String type = platformFile.extension!;

    File file = File(result.files.single.path!);

    int size = await file.length();

    if ((_sizeUploaded + size) > _max) {
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

        List<String> splittedName = platformFile.name.split(".");

        splittedName.removeLast();

        MFile mFile = MFile(
          downloadUrl: downloadUrl,
          fileName: splittedName.join(""),
          fileType: type,
          fileSize: size,
        );

        await FCloudDb.setFileInfo(mFile);

        await CustomDialog.showMyDialog(
            context: context,
            title: "Upload",
            text: "Upload successful!",
            actions: [const SimpleButton(title: "OK")]);

        _init();
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
            TextButton(onPressed: upgrade, child: const Text("Upgrade")),
            context.sizedBox(height: 0.1),
            Text("File Name: ${_file?.fileName}"),
            Text("File Type: ${_file?.fileType}"),
            Text("File Size: ${_file?.fileSize}"),
            Text("File Upload Date: ${_file?.uploadDate}"),
            context.sizedBox(height: 0.05),
            _getButton(),
            context.sizedBox(height: 0.03),
            const Divider(),
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
