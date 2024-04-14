import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_xpert/main.dart';
import 'package:shoe_xpert/screens/cart_screen.dart';
import 'package:shoe_xpert/widgets/buttons.dart';
import 'package:shoe_xpert/widgets/network_image.dart';

import '../constants.dart';
import '../models/cart.dart';
import '../models/shoes.dart';
import '../widgets/toasty.dart';

class ShoeDetailScreen extends StatefulWidget {
  const ShoeDetailScreen({super.key, required this.shoes});

  final Shoes shoes;

  @override
  State<ShoeDetailScreen> createState() => _ShoeDetailScreenState();
}

class _ShoeDetailScreenState extends State<ShoeDetailScreen> {
  late Shoes shoes;

  // List<String> colorsString = ["Orange", "Green", "Grey"];
  // List<Color> colors = [Colors.orangeAccent, Colors.green, Colors.grey];
  int selectedColorIndex = 0;
  int selectedSize = 0;
  int size = 34;
  bool isLoading = false;
  int totalItemInCart = 0;
  Cart? myCart;

  @override
  void initState() {
    shoes = widget.shoes;
    _fetchCartFromDatabase();
    super.initState();
  }

  Future<void> _fetchCartFromDatabase() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await fireStore
        .collection(cartCollection)
        .where(userDocId, isEqualTo: loggedInUser!.docId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      myCart = Cart.fromJson(snapshot.docs.first);
      totalItemInCart = myCart!.shoes!.length;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> addToCart() async {
    try {
      Shoes shoe = Shoes(
        docId: shoes.docId,
        name: shoes.name,
        image: shoes.image,
        price: shoes.price,
        size: size,
      );

      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> mp;
      print("myCart: ${myCart?.shoes}");
      if (myCart == null) {
        Cart crt = Cart(
          userId: loggedInUser!.docId,
          shoes: <Shoes>[shoe],
        );
        mp = crt.toJson();
        await fireStore.collection(cartCollection).add(mp);
      } else {
        myCart!.shoes!.add(shoe);
        mp = myCart!.toJson();
        await fireStore
            .collection(cartCollection)
            .doc(myCart!.docId)
            .set(mp, SetOptions(merge: true));
      }
      print("myCart: ${mp}");

      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                "Successfully Added to Cart",
                style: TextStyle(fontSize: 18),
              ),
              icon: const Icon(
                Icons.check_circle,
                size: 90,
                color: Colors.purple,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      // todo move to cart
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => const CartScreen(),
                      //     ));
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(fontSize: 18),
                    )),
              ],
            );
          },
        );
      }
    } catch (error) {
      Toasty.success("Some error occurred. try again later");
      setState(() {
        isLoading = false;
      });

      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text("Shoe Xpert"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Stack(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartScreen(),
                          ));
                    },
                    icon: Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.purple,
                    )),
                Positioned(
                    right: 19,
                    top: -1,
                    child: Text(
                      totalItemInCart.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.purple),
                    )),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              imageContainer(shoes.image!),
              // Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${shoes.name}",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: pink,
                    ),
                  ),
                  Text(
                    "Price: ${shoes.price} CAD",
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                      "${shoes.name} is an American brand of basketball shoes athletic, casual and style clothing produced by Nike."),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Select size:",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    children: List.generate(10, (index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedSize = index;
                            size = 34 + index;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(5),
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                              border: index == selectedSize
                                  ? Border.all(color: Colors.purple, width: 2)
                                  : Border.all(color: Colors.transparent)),
                          child: Center(child: Text("${34 + index}")),
                        ),
                      );
                    }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: ${shoes.price} cad",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                      Flexible(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.purple,
                                )
                              : MyButton(
                                  onPressed: () {
                                    addToCart();
                                  },
                                  text: "Add To Cart"),
                        ),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
