// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pacervtu/constants.dart';
import 'package:pacervtu/src/auth/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zzquqfjainyvsmiaolgq.supabase.co',
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6cXVxZmphaW55dnNtaWFvbGdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3MjQ3MTksImV4cCI6MjA3ODMwMDcxOX0.dBfaY1kWTo_gZtMH0VRMT9MWZQHE5-nwkqcpal_-MhI',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
    storageOptions: const StorageClientOptions(
      retryAttempts: 10,
    ),
  );


  runApp( ProviderScope(
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home:const Loadingpage()
    ),
  ));
}

class Loadingpage extends StatefulWidget {
  const Loadingpage({super.key});

  @override
  State<Loadingpage> createState() => _LoadingpageState();
}

class _LoadingpageState extends State<Loadingpage>
    with SingleTickerProviderStateMixin {


  @override
  void initState() {
    super.initState();

    // Status bar color & immersive mode
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);


    Future.delayed(const Duration(seconds: 6), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppData.appTheme,
      body: SafeArea(child: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 95,
            backgroundColor: AppData.lightTheme,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image(image:AssetImage(AppData.logo),),
            )
          ),
          SizedBox(height: 25,),
          Text(AppData.appName, 
            style: GoogleFonts.roboto(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),),
          SizedBox(width: 25,),
          Text(AppData.appIntroMessage, 
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: AppData.lightTheme.withAlpha(150),
            ),),
            SizedBox(height: 90,),
            Center(
              child: LoadingAnimationWidget.progressiveDots(
                color: Colors.white,
                size: 50,
              ),)
        ],
      ),
      )),

    );
  }
}