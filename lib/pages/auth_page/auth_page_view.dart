import 'package:all_drop/common_libs.dart';
import 'package:all_drop/core/firebase/f_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:uikit/uikit.dart';

class AuthPageView extends StatefulWidget {
  const AuthPageView({super.key});

  @override
  State<AuthPageView> createState() => _AuthPageViewState();
}

class _AuthPageViewState extends State<AuthPageView> {
  late TextEditingController _tECUsername;
  late TextEditingController _tECPassword;

  @override
  void initState() {
    super.initState();
    _tECUsername = TextEditingController();
    _tECPassword = TextEditingController();
  }

  @override
  void dispose() {
    _tECUsername.dispose();
    _tECPassword.dispose();

    super.dispose();
  }

  Future<void> _logIn() async {
    CustomProgressIndicator().showProgressIndicator(context);

    bool result = await FAuth.logIn(
        context, _tECUsername.textTrim, _tECPassword.textTrim);

    if (result) {
      context.go("/");
    }
  }

  Future<void> _signUp() async {
    CustomProgressIndicator().showProgressIndicator(context);

    bool result = await FAuth.signUp(
        context, _tECUsername.textTrim, _tECPassword.textTrim);

    if (result) {
      context.go("/");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(controller: _tECUsername),
            TextField(
              controller: _tECPassword,
            ),
            ElevatedButton(onPressed: _logIn, child: const Text("Log In")),
            TextButton(onPressed: _signUp, child: const Text("Sign Up"))
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text("AllDrop"),
    );
  }
}
