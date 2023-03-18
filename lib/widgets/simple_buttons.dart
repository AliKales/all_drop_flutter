import 'package:all_drop/common_libs.dart';

class SimpleButton extends StatelessWidget {
  const SimpleButton({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(title));
  }
}
