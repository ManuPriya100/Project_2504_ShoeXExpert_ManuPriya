import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_xpert/main.dart';
import 'package:shoe_xpert/models/shoes.dart';
import 'package:shoe_xpert/screens/cart_screen.dart';
import 'package:shoe_xpert/screens/shoe_detail.dart';
import 'package:shoe_xpert/screens/signin_screen.dart';
import 'package:shoe_xpert/screens/splash.dart';

import '../constants.dart';
import '../widgets/network_image.dart';
import 'admin/display_all_shoes_admin.dart';
import 'orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        key: _key,
        drawer: userDrawer(),
        body: Column(
          children: [
            SizedBox(
              height: 65,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () {
                          _key.currentState!.openDrawer();
                        },
                        icon: Icon(Icons.menu))),
                Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Welcome to Shoe Xpert",
                          style: TextStyle(
                              fontSize: 25,
                              color: pink,
                              fontWeight: FontWeight.w700),
                        ))),
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () async {
                          await prefs.clear();

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SplashScreen(),
                              ),
                              (route) => false);
                        },
                        icon: const Icon(Icons.logout))),
              ],
            ),
            Expanded(
              child: shoeGrid(),
            )
          ],
        ),
      ),
    );
  }

  shoeGrid() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: StreamBuilder(
        stream: fireStore.collection(shoesCollection).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (snapshot.data != null && snapshot.data!.size < 1) {
            const Center(
              child: Text("Shoes not found"),
            );
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final shoe =
                    Shoes.fromQueryDocument(snapshot.data!.docs[index]);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoeDetailScreen(shoes: shoe),
                        ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: pink.withOpacity(0.1),
                        border: Border.all(color: Colors.grey.shade200)),
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: imageContainer(shoe.image!),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${shoe.name}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: pink,
                                ),
                              ),
                              Text(
                                "Price: ${shoe.price} CAD",
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  userDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Text(
              textAlign: TextAlign.center,
              "Hello ${loggedInUser!.name}\nWelcome to Shoe Xpert",
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: pink),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          pink.withAlpha(10),
                          Colors.pinkAccent.withAlpha(150)
                        ],
                      )),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartScreen(),
                          ));
                    },
                    title: Text("Cart"),
                    leading: Icon(Icons.add_shopping_cart_rounded),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          pink.withAlpha(10),
                          Colors.pinkAccent.withAlpha(150)
                        ],
                      )),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrdersScreen(),
                          ));
                    },
                    title: Text("Orders"),
                    leading: Icon(Icons.shopping_bag_outlined),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListTile(
              onTap: () {},
              title: TextButton(
                  onPressed: () async {
                    await prefs.clear();

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SplashScreen(),
                        ),
                        (route) => false);
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(color: pink, fontSize: 20),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
