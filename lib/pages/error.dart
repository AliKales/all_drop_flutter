import 'package:all_drop/common_libs.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.error});
  final String error;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(error),
            ],
          ),
        ),
      ),
    );
  }
}
