import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ussd_dialer/providers/ExcelProvider.dart';
import 'package:ussd_dialer/providers/LicenseProvider.dart';
import 'package:ussd_dialer/providers/SimsProvider.dart';
import 'package:ussd_dialer/providers/UssdProvider.dart';
import 'package:ussd_dialer/screens/HomeScreen.dart';
import 'package:ussd_dialer/widgets/IsLoadingWidget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.phone.request();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SimsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ExcelProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UssdProvider(),
        ),ChangeNotifierProvider(
          create: (context) => LicenseProvider(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        builder: EasyLoading.init(),
        home: Consumer<LicenseProvider>(
          builder: (context, value, child) {
            if(value.isLoaded){
              if(value.isLicense){
                return HomeScreen();
              }else{
                return Center(
                  child: Text("no license"),
                );
              }
            }else{
              value.getAppStatus();
            }
            return IsLoadingWidget();
          },
        ),
      ),
    );
  }
}
