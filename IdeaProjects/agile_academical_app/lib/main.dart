import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'user_list.dart';
import 'common/styles/themes.dart';
import 'firebase_options.dart';
import 'package:responsive_spacing/responsive_spacing.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ResponsiveSpacing.setDefaults(
    globalSpacing: MySimpleSpacing(),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: AppTheme.lightTheme,
      initialRoute: '/login' ,
      getPages: [
        GetPage(name: '/login', page: () => LoginPage())
      ],


    );
  }
}

class MySimpleSpacing extends SpacingCollection {

  @override
  SimpleSpacing get any => const SimpleSpacing(
    xs: 2.0,
    s: 8.0,
    m: 12.0,
    l: 16.0,
    xl: 32.0,
    xxl: 56.0,
  );
}
