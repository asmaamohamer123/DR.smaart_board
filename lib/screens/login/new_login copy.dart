import 'package:attendance/screens/home/home_screen.dart';
import 'package:attendance/screens/register_screen/Register_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(' !!! حدث خطأ '),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('نعم'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text(' ...جاري تسجيل الدخول'),
          ],
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context).pop();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    final RegExp emailRegExp = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return ' يرجي كتابه البريد الإلكتروني بشكل صحيح  ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  GlobalKey<FormState> formkey = GlobalKey();

  bool showpassword = true;
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool spiner = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
       // appBar: AppBar(),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(25, 50, 25, 0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 250,
                        width: 250,
                        child: Image.asset('assets/images/splash.png'),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onFieldSubmitted: (String value) {},
                      onChanged: (String value) {
                        email = value;
                      },
                     validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'عنوان البريد الالكترونى',
                        prefixIcon: Icon(
                          Icons.email,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: showpassword,
                      onFieldSubmitted: (String value) {},
                      onChanged: (String value) {
                        password = value;
                      },
                      validator: _validatePassword,
                      decoration: InputDecoration(
                        labelText: 'كلمه المرور',
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              showpassword = !showpassword;
                            });
                          },
                          icon: showpassword
                              ? const Icon(Icons.visibility_off)
                              : const Icon(
                                  Icons.visibility,
                                ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Material(
                            elevation: 5,
                            color: const Color(0xff2e386b),
                            borderRadius: const BorderRadius.all(
                                Radius.circular(20)),
                            child: MaterialButton(
                              onPressed: () async {
                                if (formkey.currentState!.validate()) {
                                  formkey.currentState!.save();
                                  _showLoadingDialog();
                                  //spiner=true;
                                  try {
                                    final user = await _auth
                                        .signInWithEmailAndPassword(
                                            email: email,
                                            password: password);
                                    _hideLoadingDialog();
                                   //spiner=false;
                                    if (user != null) {
                                      setState(() {
                                        var router = MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                             HomeScreens(),
                                        );
                                        Navigator.of(context).push(router);
                                      //  spiner = false;
                                      });
                                    }
                                  } catch (e) {
                                    _hideLoadingDialog();
                                    _showErrorDialog(
                                        ' البريد الإلكتروني أو كلمة المرور غير صحيحة. حاول مرة اخرى');
                                  }
                                } else {
                                  setState(() {
                                    spiner = false;
                                  });
                                }
                              },
                              minWidth: 50,
                              height: 20,
                              child: const Text(
                                'تسجيل دخول ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                     
                     
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
