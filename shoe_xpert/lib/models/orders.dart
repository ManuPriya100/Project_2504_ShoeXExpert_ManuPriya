import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoe_xpert/constants.dart';
import 'package:shoe_xpert/models/shoes.dart';

import 'cart.dart';

class Orders {
  String? id;
  Cart? cartItem;
  String? userId;

  int? price;
  String? status;
  int? creationTime;

  Orders({this.id, this.cartItem, this.price, this.status, this.creationTime, this.userId});

  factory Orders.fromJson(QueryDocumentSnapshot mp) {
    Map json = mp.data() as Map;
    Map cartData = json['cartItem'];
    print("cartData: $cartData");

    Cart cartList =Cart.fromOrderJson(cartData);

    return Orders(
      id: mp.id.toString(),
      cartItem: cartList,
      userId: json[userDocId],
      price: json['price'],
      status: json['status'],
      creationTime: json['creationTime'],
    );
  }

  Map<String, dynamic> toJson() {
   Map cartListJson = cartItem!.toJson();
    return {
      'cartItem': cartListJson,
      'price': price,
      'status': status,
      userDocId: userId,
      'creationTime': creationTime,
    };
  }
}
