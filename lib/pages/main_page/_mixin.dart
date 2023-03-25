part of 'main_page_view.dart';

mixin _Mixin<T extends StatefulWidget> on State<T> {
  void upgrade() {
    CustomDialog.showMyDialog(
        context: context,
        title: "Upgrade",
        text: "To upgrade your total size, please contact us via email!",
        actions: [
          TextButton(onPressed: copyEmail, child: const Text("Copy Email")),
        ]);
  }

  void copyEmail() {
    context.back();
    Utils.copyToClipBoard(
        "suggestionsandhelp@hotmail.com", "Email copied!", context);
  }
}
