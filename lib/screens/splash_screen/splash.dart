 
import 'dart:async';

//import 'package:attendance/screens/new_login.dart';
import 'package:attendance/screens/login/new_login%20copy.dart';
import 'package:attendance/screens/register_screen/Register_Screen.dart';
import 'package:flutter/material.dart';

//import '../login/new_login.dart';


 
 

class SplashScreen extends StatefulWidget {
  //route name for our screen
  static String routeName = 'SplashScreen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //we use future to go from one screen to other via duration time
  //  Future.delayed(Duration(seconds: 5), (){
      //no return when user is on login screen and press back, it will not return the
      //user to the splash screen
   //   Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
    //});
    
    // بدء مؤقت لمدة ثلاثه ثوانٍ
    Timer(const Duration(seconds: 3), () {
      // الانتقال إلى شاشة تسجيل الدخول بعد انتهاء المؤقت
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    //scaffold color set to primary color in main in our text theme
    return Scaffold(
      backgroundColor: Colors.white,
      //its a row with a column
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 SizedBox(
                        height: 300,
                        width: 300,
                        child: Image.asset('assets/images/splash.png'),
                      ),

                      const SizedBox(
                    height: 0.0,
                  ),
            const Row(
              children:[
                 Text('السبوره الالكترونيه'      , 
                 style: TextStyle(
                         // color: Colors.black26,
                          //color: Color(0xff2e386b),
                           color: Color.fromARGB(255, 13, 73, 194),
                          fontSize: 30,
                           fontWeight: FontWeight.bold,
                         ),
                 ),
              ],
              ),
              ],
            ),
            // Center(
            //             child:
            //            Container(
            //             height: 180,
            //             child: Image.asset('assets/images/welcom.png'),
            //           ),
            //           ),

          ],
        ),
      ),
    );
  }
}
