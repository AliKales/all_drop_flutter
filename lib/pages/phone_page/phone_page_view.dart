// ignore_for_file: use_build_context_synchronously

import 'package:all_drop/common_libs.dart';
import 'package:all_drop/core/firebase/f_auth.dart';
import 'package:all_drop/router.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:uikit/uikit.dart';

class PhonePageView extends StatefulWidget {
  const PhonePageView({super.key});

  @override
  State<PhonePageView> createState() => _PhonePageViewState();
}

class _PhonePageViewState extends State<PhonePageView> {
  final PageController _pC = PageController();
  final TextEditingController _tECPhone = TextEditingController();
  final TextEditingController _tECCode = TextEditingController();
  String _smsCode = "";

  @override
  void dispose() {
    _pC.dispose();
    _tECPhone.dispose();
    _tECCode.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (_tECPhone.textTrim == "") return;
    FAuth.verifyPhoneNumber(
      codeSent: () {
        _changePage();
      },
      onError: (error) {
        CustomSnackbar.showSnackBar(context: context, text: error);
      },
      phoneNumber: "+${_tECPhone.textTrim}",
    );
  }

  Future<void> _updatePhoneNumber() async {
    if (_smsCode.length < 6) return;

    String result = await FAuth.updatePhoneNumber(_smsCode);

    if (result == "") {
      context.go(PagePaths.main);
    } else {
      CustomSnackbar.showSnackBar(context: context, text: result);
    }
  }

  void _logOut() async {
    await FAuth.logOut();
    context.go(PagePaths.auth);
  }

  void _changePage() {
    int page;
    if (_pC.page!.toInt() == 0) {
      page = 1;
    } else {
      page = 0;
    }

    _pC.animateToPage(page, duration: 300.toDuration, curve: Curves.ease);
  }

  void _back() {
    _tECPhone.clear();
    _smsCode = "";
    _tECCode.clear();
    _changePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: PageView(
        controller: _pC,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _phoneWidget(),
          _pinCodeWidget(),
        ],
      ),
    );
  }

  Widget _phoneWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Spacer(),
          TextField(
            controller: _tECPhone,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: "Phone Number (Country code required!)",
                prefixText: "+"),
          ),
          const Spacer(),
          FilledButton(
            onPressed: _sendCode,
            child: const Text("SEND CODE"),
          ),
          TextButton(onPressed: _back, child: Text("BACK")),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _pinCodeWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Spacer(),
          PinCodeTextField(
            appContext: context,
            controller: _tECCode,
            length: 6,
            onChanged: (value) => _smsCode = value,
          ),
          const Spacer(),
          FilledButton(
            onPressed: _updatePhoneNumber,
            child: const Text("VERIFY"),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text("Verify Phone Number"),
      actions: [
        IconButton(
          onPressed: _logOut,
          color: Colors.red,
          icon: Icon(Icons.logout),
        ),
      ],
    );
  }
}