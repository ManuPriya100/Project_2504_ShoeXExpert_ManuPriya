import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoe_xpert/constants.dart';
import 'package:shoe_xpert/main.dart';
import 'package:shoe_xpert/models/orders.dart';
import 'package:shoe_xpert/widgets/network_image.dart';

import '../models/cart.dart';
import '../models/shoes.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Orders> allOrders = [];
  bool isLoading = true;
  late String userKey;

  @override
  void initState() {
    _fetchOrdersFromDatabase();
    super.initState();
  }

  Future<void> _fetchOrdersFromDatabase() async {
    QuerySnapshot<Map<String, dynamic>> doc = await fireStore
        .collection(orderCollection)
        .where(userDocId, isEqualTo: loggedInUser!.docId)
        .get();
    List<Orders> orderList = [];
    if (doc.size > 0) {
      for (QueryDocumentSnapshot entry in doc.docs) {
        Orders ord = Orders.fromJson(entry);
        orderList.add(ord);
      }
    }
    setState(() {
      allOrders = orderList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text("Your Orders"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : Column(
                children: [
                  allOrders.isEmpty
                      ? const Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 100,
                              ),
                              Icon(
                                Icons.shopping_basket_outlined,
                                size: 70,
                                color: Colors.grey,
                              ),
                              Text(
                                "You have not placed any order yet.",
                                textAlign: TextAlign.center,
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
                            itemCount: allOrders.length,
                            itemBuilder: (context, index) {
                              Orders order = allOrders[index];

                              DateTime dateTime =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      order.creationTime!);
                              return Container(
                                padding: const EdgeInsets.only(
                                    top: 8, bottom: 8, left: 8, right: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.grey.shade200)),
                                margin: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Status: ${order.status}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 22,
                                          color: pink),
                                    ),
                                    Text(
                                      "Created on: ${dateTime.day}/${dateTime.month}/${dateTime.year}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      "Total Items: ${order.cartItem!.shoes!.length}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      "Paid Price: ${order.price} cad",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                    ExpansionTile(
                                        childrenPadding: EdgeInsets.zero,
                                        title: const Text(
                                          "View Details",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        children: List.generate(
                                            order.cartItem!.shoes!.length,
                                            (index1) {
                                          Cart crt = order.cartItem!;
                                          Shoes shoe = crt.shoes![index1];
                                          return Container(
                                            // height: 200,
                                            padding: const EdgeInsets.only(
                                                top: 8, bottom: 8),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200)),
                                            margin: EdgeInsets.all(8),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: imageContainer(
                                                          shoe.image!),
                                                    )
                                                    // minRadius: 50,
                                                    ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        shoe.name!,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16,
                                                            color: pink),
                                                      ),
                                                      Text(
                                                        "${shoe.price} cad",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        "Size: ${shoe.size}",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }))
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                ],
              ),
      ),
    );
  }
}
