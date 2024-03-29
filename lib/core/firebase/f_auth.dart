// ignore_for_file: use_build_context_synchronously

import 'package:all_drop/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:uikit/uikit.dart';

import '../../common_libs.dart';

enum LastProgress { signUp, logIn }

class FAuth {
  static String _verificationId = "";

  static String lastEmail = "";
  static String lastPassword = "";
  static LastProgress? lastProgress;

  static bool get isEmailVerified =>
      FirebaseAuth.instance.currentUser?.emailVerified ?? false;

  static bool get isSignedIn =>
      FirebaseAuth.instance.currentUser == null ? false : true;

  static String? get getEmail => FirebaseAuth.instance.currentUser?.email;
  static String? get getUid => FirebaseAuth.instance.currentUser?.uid;
  static String? get getPhone =>
      FirebaseAuth.instance.currentUser?.phoneNumber ?? "";

  static PhoneAuthCredential? pAC;

  static void sendVerification() =>
      FirebaseAuth.instance.currentUser!.sendEmailVerification();

  static Future reload([BuildContext? context]) async {
    await FirebaseAuth.instance.currentUser!.reload();
  }

  static Future<bool> signUp(
      BuildContext context, String emailAddress, String password) async {
    if ((lastProgress ?? true) != LastProgress.signUp) {
      lastEmail = "";
      lastPassword = "";
      lastProgress = LastProgress.signUp;
    }

    ///Here it saves last email and password if there's an error about it so on next try it checks if its same or not
    if (emailAddress == lastEmail) {
      _onAuthException('email-already-in-use', password, context, emailAddress);
      return false;
    }
    if (password == lastPassword) {
      _onAuthException('weak-password', password, context, emailAddress);
      return false;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      Navigator.pop(context);

      return true;
    } on FirebaseAuthException catch (e) {
      _onAuthException(e.code, password, context, emailAddress);

      return false;
    } catch (e) {
      CustomSnackbar.showSnackBar(context: context, text: "ERROR!");
      return false;
    }
  }

  static Future<bool> logIn(
      context, String emailAddress, String password) async {
    if ((lastProgress ?? true) != LastProgress.logIn) {
      lastEmail = "";
      lastPassword = "";
      lastProgress = LastProgress.logIn;
    }

    ///Here it saves last email and password if there's an error about it so on next try it checks if its same or not
    if (emailAddress == lastEmail) {
      _onAuthException('email-already-in-use', password, context, emailAddress);
      return false;
    }
    if (password == lastPassword) {
      _onAuthException('weak-password', password, context, emailAddress);
      return false;
    }

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);

      Navigator.pop(context);

      return true;
    } on FirebaseAuthException catch (e) {
      _onAuthException(e.code, password, context, emailAddress);
      return false;
    }
  }

  static Future<bool> logOut() async {
    await FirebaseAuth.instance.signOut();
    return true;
  }

  static void _onAuthException(
      String e, String password, BuildContext context, String emailAddress) {
    Navigator.pop(context);

    if (e == 'weak-password') {
      lastPassword = password;
      CustomSnackbar.showSnackBar(
          context: context, text: 'The password provided is too weak.');
      return;
    } else if (e == 'email-already-in-use') {
      lastEmail = emailAddress;
      CustomSnackbar.showSnackBar(
          context: context, text: "The account already exists for that email.");
      return;
    } else if (e == 'invalid-email') {
      lastEmail = emailAddress;
      CustomSnackbar.showSnackBar(context: context, text: "Invalid email!");
      return;
    }

    if (e == 'user-not-found') {
      lastEmail = emailAddress;
      CustomSnackbar.showSnackBar(
          context: context, text: 'Wrong email or password!');
      return;
    } else if (e == 'wrong-password') {
      lastPassword = password;
      CustomSnackbar.showSnackBar(
          context: context, text: 'Wrong email or password!');
      return;
    }

    CustomSnackbar.showSnackBar(
        context: context, text: 'Something went wrong!');
  }

  static Future verifyPhoneNumber({
    required VoidCallback codeSent,
    required Function(String error) onError,
    required String phoneNumber,
  }) async {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (phoneAuthCredential) async {
        pAC = phoneAuthCredential;
        codeSent.call();
      },
      verificationFailed: (error) {
        onError.call(error.message ?? "Error");
      },
      codeSent: (verificationId, forceResendingToken) {
        _verificationId = verificationId;
        codeSent.call();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
        codeSent.call();
      },
    );
  }

  static Future<String> updatePhoneNumber(
    String smsCode,
  ) async {
    try {
      var phoneAuthCredential = pAC ??
          PhoneAuthProvider.credential(
              verificationId: _verificationId, smsCode: smsCode);

      await FirebaseAuth.instance.currentUser
          ?.updatePhoneNumber(phoneAuthCredential);
      return "";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Error";
    } catch (_) {
      return "Error";
    }
  }

  static Future<bool> reAuth(String email, String password) async {
    var credential =
        EmailAuthProvider.credential(email: email, password: password);

    await FirebaseAuth.instance.currentUser
        ?.reauthenticateWithCredential(credential);

    return true;
  }
}
