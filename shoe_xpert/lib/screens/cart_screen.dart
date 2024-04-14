import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_xpert/constants.dart';
import 'package:shoe_xpert/models/cart.dart';
import 'package:shoe_xpert/models/orders.dart';
import 'package:shoe_xpert/widgets/buttons.dart';
import 'package:shoe_xpert/widgets/network_image.dart';
import 'package:shoe_xpert/widgets/toasty.dart';

import '../main.dart';
import '../models/shoes.dart';
import 'input_card_details.dart';
import 'orders_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Cart? myCart;
  int totalPrice = 0;
  bool isLoading = true;
  late String userKey;
  int totalItemInCart = 0;

  @override
  void initState() {
    _fetchCartFromDatabase();
    super.initState();
  }

  Future<void> _fetchCartFromDatabase() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await fireStore
        .collection(cartCollection)
        .where(userDocId, isEqualTo: loggedInUser!.docId)
        .get();
    totalPrice = 0;

    if (snapshot.docs.isNotEmpty) {
      myCart = Cart.fromJson(snapshot.docs.first);
      totalItemInCart = myCart!.shoes!.length;
      for (Shoes shoe in myCart!.shoes!) {
        totalPrice = totalPrice + shoe.price!;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  placeOrder() {
    try {
      setState(() {
        isLoading = true;
      });
      Orders ord = Orders(
        cartItem: myCart,
        userId: myCart!.userId,
        price: totalPrice,
        creationTime: DateTime.now().millisecondsSinceEpoch,
        status: "Approved",
      );

      fireStore.collection(orderCollection).add(ord.toJson()).then((_) async {
        await clearCart();
        setState(() {
          isLoading = false;
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Order placed successfully",
                  style: TextStyle(fontSize: 18),
                ),
                icon: Icon(
                  Icons.check_circle,
                  size: 90,
                  color: Colors.purple,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => OrdersScreen(),
                        //     ));
                      },
                      child: Text(
                        "OK",
                        style: TextStyle(fontSize: 18),
                      )),
                ],
              );
            },
          );
        });
      });
    } catch (e) {
      Toasty.error("Some error occurred, Try again later");
      setState(() {
        isLoading = false;
      });
      print("error: $e");
    }
  }

  clearCart() async {
    await fireStore.collection(cartCollection).doc(myCart!.docId).delete();
  }

  Future<void> updateCart(int index) async {
    try {
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> mp;
      Future<DocumentReference<Map<String, dynamic>>> docRef;
      print("myCart: ${myCart?.shoes}");
      myCart!.shoes!.removeAt(index);
      mp = myCart!.toJson();
      await fireStore
          .collection(cartCollection)
          .doc(myCart!.docId)
          .set(mp, SetOptions(merge: true));

      _fetchCartFromDatabase();
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
        title: Text("Your Cart"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : Column(
                children: [
                  totalItemInCart == 0
                      ? const Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 100,
                              ),
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 70,
                                color: Colors.grey,
                              ),
                              Text(
                                "Your Cart is Empty",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 25,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                          itemCount: myCart!.shoes!.length,
                          itemBuilder: (context, index) {
                            // Cart crt = myCart!.shoes![index];
                            Shoes shoe = myCart!.shoes![index];
                            return Container(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      Border.all(color: Colors.grey.shade200)),
                              margin: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        width: 120,
                                        child: imageContainer(shoe.image!),
                                      )
                                      // minRadius: 50,
                                      ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${shoe.name!}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color: pink),
                                        ),
                                        Text(
                                          "Price: ${shoe.price} cad",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          "Size: ${shoe.size}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      updateCart(index);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.delete_forever_outlined,
                                        color: Colors.black54,
                                        size: 28,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        )),
                  totalItemInCart == 0
                      ? SizedBox.shrink()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total: $totalPrice cad",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: MyButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddNewCardScreen(),
                                        )).then((value) {
                                      if (value != null) {
                                        placeOrder();
                                      } else {
                                        Toasty.error(
                                            "Card details not provided");
                                      }
                                    });
                                  },
                                  text: "Place Order",
                                ),
                              ),
                            )
                          ],
                        )
                ],
              ),
      ),
    );
  }
}
