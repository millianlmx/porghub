import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorManager extends InheritedWidget {
  const ColorManager({Key? key, required Widget child, required this.color})
      : super(
          child: child,
          key: key,
        );
  final ValueNotifier<Color> color;

  @override
  bool updateShouldNotify(ColorManager oldWidget) =>
      oldWidget.color.value != color.value;

  static ColorManager of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ColorManager>()!;

  void changeColor(Color color) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt("r", color.red);
    await preferences.setInt("g", color.green);
    await preferences.setInt("b", color.blue);
    this.color.value = color;
  }
}

Future<Color> getSeedColor() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  try {
    int r = preferences.getInt("r")!;
    int g = preferences.getInt("g")!;
    int b = preferences.getInt("b")!;
    return Color.fromARGB(255, r, g, b);
  } catch (e) {
    await preferences.setInt("r", 245);
    await preferences.setInt("g", 162);
    await preferences.setInt("b", 38);
    return const Color.fromARGB(255, 245, 162, 38);
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètre"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ColorPicker(
              pickerColor: ColorManager.of(context).color.value,
              onColorChanged: ColorManager.of(context).changeColor,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
            child: const Text("Se déconnecter"),
          ),
          const SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }
}
