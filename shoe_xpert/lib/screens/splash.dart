import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_xpert/models/user.dart';
import 'package:shoe_xpert/screens/signin_screen.dart';

import '../constants.dart';
import '../main.dart';
import '../widgets/buttons.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading = false;

  verifyNavigate() async {
    setState(() {
      isLoading = true;
    });

    if (prefs.containsKey(userEmail)) {
      // it means already login(session exist)
      UserModel user = UserModel(
        docId: prefs.getString(userDocId),
        password: prefs.getString(userPassword),
        email: prefs.getString(userEmail),
        name: prefs.getString(username),
      );
      loggedInUser = user;
      selectedUserRole = UserRole.user;
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ));
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    verifyNavigate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 130,
            ),
            Image.asset(
              "${imagePath}shoes.png",
              width: MediaQuery.of(context).size.width * 0.55,
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Welcome to Shoe Xpert",
              style: TextStyle(
                  fontSize: 25, color: pink, fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 30,
            ),
            ...!isLoading
                ? [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Select your role!",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyButton(
                      text: "Admin",
                      onPressed: () async {
                        selectedUserRole = UserRole.admin;
                        await Future.delayed(Duration(milliseconds: 200));

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInScreen(),
                            ));
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyButton(
                        onPressed: () async {
                          selectedUserRole = UserRole.user;
                          await Future.delayed(Duration(milliseconds: 200));

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInScreen(),
                              ));
                        },
                        text: "User"),
                  ]
                : [
                    SizedBox(
                      height: 35,
                    ),
                    SpinKitSpinningLines(
                      color: pink,
                      duration: Duration(seconds: 1),
                      lineWidth: 5,
                      itemCount: 5,
                    ),
                  ],
          ],
        ),
      ),
    );
  }
}
