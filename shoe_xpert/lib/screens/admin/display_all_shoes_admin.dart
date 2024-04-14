import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_xpert/models/shoes.dart';
import 'package:shoe_xpert/screens/admin/add_shoes.dart';
import 'package:shoe_xpert/screens/cart_screen.dart';
import 'package:shoe_xpert/screens/shoe_detail.dart';
import 'package:shoe_xpert/screens/signin_screen.dart';

import '../../constants.dart';
import '../../main.dart';
import '../../widgets/network_image.dart';
import '../splash.dart';

class DisplayAllShoesAdmin extends StatefulWidget {
  const DisplayAllShoesAdmin({super.key});

  @override
  State<DisplayAllShoesAdmin> createState() => _DisplayAllShoesAdminState();
}

class _DisplayAllShoesAdminState extends State<DisplayAllShoesAdmin> {
  List<Shoes> allShoes = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              )
            : Column(
                children: [
                  SizedBox(
                    height: 65,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SplashScreen(),
                                    ),
                                    (route) => false);
                              },
                              icon: Icon(Icons.logout))),
                    ],
                  ),
                  Expanded(
                    child: shoeGrid(),
                  )
                ],
              ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddShoes(),
                  ));
            },
            child: Icon(Icons.add)),
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
                  onTap: () {},
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
}
