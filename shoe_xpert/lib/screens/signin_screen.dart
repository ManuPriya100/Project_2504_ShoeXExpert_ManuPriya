import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_xpert/constants.dart';
import 'package:shoe_xpert/screens/admin/display_all_shoes_admin.dart';
import 'package:shoe_xpert/screens/signup_screen.dart';
import 'package:shoe_xpert/widgets/buttons.dart';
import 'package:shoe_xpert/widgets/toasty.dart';

import '../main.dart';
import '../models/user.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 90),
                Text(
                  "Hello Again!",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple),
                ),
                SizedBox(height: 20),
                Text("Welcome Back You've Been Missed!"),
                SizedBox(height: 40),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter email" : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                    hintText: "Enter password",
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter password" : null,
                ),
                SizedBox(height: 15),
                isLoading
                    ? CircularProgressIndicator(
                        color: Colors.purple,
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: MyButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                loginUser(
                                    emailController.text.trim().toLowerCase(),
                                    passwordController.text.trim());
                              }
                            },
                            text: "Login"),
                      ),
                SizedBox(height: 20),
                selectedUserRole == UserRole.admin
                    ? SizedBox.shrink()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Don't have an account? "),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpScreen(),
                                    ));
                              },
                              child: Text("Signup")),
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginUser(String email, String password) async {
    try {
      setState(() {
        isLoading = true;
      });
      // Check if a document with the same email already exists
      QuerySnapshot querySnapshot = await fireStore
          .collection(selectedUserRole == UserRole.admin
              ? adminCollection
              : userCollection)
          .where('email', isEqualTo: email)
          .get();

      // If no document with the same email exists, insert the new user
      if (querySnapshot.docs.isEmpty) {
        Toasty.error('Error: Profile not found');
      } else {
        QueryDocumentSnapshot doc = querySnapshot.docs.first;
        UserModel user = UserModel.fromJson(doc);
        if (user.password != password) {
          Toasty.error('Error: Password not correct');
        } else {
          Toasty.success('Success: Profile found');
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          if (selectedUserRole == UserRole.user) {
            await prefs.setString(userDocId, user.docId!);
            await prefs.setString(username, user.name!);
            await prefs.setString(userEmail, user.email!);
            await prefs.setString(userPassword, user.password!);
          }
          loggedInUser = user;

          await Future.delayed(const Duration(milliseconds: 2000));
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => selectedUserRole == UserRole.admin
                    ? DisplayAllShoesAdmin()
                    : HomeScreen(),
              ));
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (error) {
      // Handle any errors that occur during the process
      print('Error: $error');
      Toasty.error('Error: Email not exists!');
    }
    setState(() {
      isLoading = false;
    });
  }
}
