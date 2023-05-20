// ignore_for_file: use_build_context_synchronously

part of 'main_page_view.dart';

mixin _Mixin<T extends StatefulWidget> on State<T> {
  void upgrade() {
    launchUrlString("https://alldrop.net/upgrade.html?uid=${FAuth.getUid}",
        mode: LaunchMode.externalApplication);
  }

  void copyEmail() {
    context.back();
    Utils.copyToClipBoard(
        "suggestionsandhelp@hotmail.com", "Email copied!", context);
  }

  Future<void> checkVersionAndAvailable() async {
    if (version != Settings.settings!.version) {
      await CustomDialog.showMyDialog(
          context: context,
          title: "Update Available!",
          text: "Please update to continue using AllDrop!",
          barrierDismissible: false);
    }

    if (Settings.settings!.isAvailable == false) {
      await CustomDialog.showMyDialog(
          context: context,
          title: "Not Available!",
          text:
              "Servers are not available for now. We are sorry about this. We will send you a notification when servers are ready!",
          barrierDismissible: false);
    }
  }
}
