import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_xpert/widgets/buttons.dart';
import 'package:shoe_xpert/widgets/toasty.dart';

import '../constants.dart';
import '../main.dart';
import '../models/user.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // FirebaseDatabase.instance.ref().child('users');
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  List<UserModel> existingUsers = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> checkAndInsertUser(
      String name, String email, String password) async {
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
        await fireStore
            .collection(selectedUserRole == UserRole.admin
                ? adminCollection
                : userCollection)
            .doc(email)
            .set({
          'name': name,
          'email': email,
          'password': password,
        });
        Toasty.success('Account created successfully!');
        print('User inserted successfully!');
        if (mounted) Navigator.pop(context);
      } else {
        // If a document with the same email exists, print an error message
        Toasty.error('Error: This email already exists!');
        print('Error: Email already exists!');
      }
    } catch (error) {
      // Handle any errors that occur during the process
      print('Error: $error');
      Toasty.error('Error: $error');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 90),
                Text(
                  "Create Account",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple),
                ),
                SizedBox(height: 20),
                Text(
                  "Let's Create Account Togather",
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    hintText: "Enter name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter name" : null,
                ),
                SizedBox(height: 15),
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
                                checkAndInsertUser(
                                    nameController.text.trim(),
                                    emailController.text.toLowerCase().trim(),
                                    passwordController.text.trim());
                              }
                            },
                            text: "Create"),
                      ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Already have an account? "),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ));
                        },
                        child: Text("Signin")),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
