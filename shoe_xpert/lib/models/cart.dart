import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoe_xpert/constants.dart';
import 'package:shoe_xpert/models/shoes.dart'; // Import any necessary constants

class Cart {
  String? docId;
  String? userId;
  List<Shoes>? shoes;

  Cart({this.docId, this.userId, this.shoes});

  factory Cart.fromJson(QueryDocumentSnapshot document) {
    Map<String, dynamic> json = document.data() as Map<String, dynamic>;
    List<dynamic>? shoesJson = json['shoes']; // Assuming 'shoes' is the key for shoes data
    List<Shoes> shoesList = shoesJson != null
        ? shoesJson.map((shoeJson) => Shoes.fromJson(shoeJson)).toList()
        : [];
    return Cart(
      docId: document.id,
      userId: json[userDocId],
      shoes: shoesList,
    );
  }
  factory Cart.fromOrderJson(Map json) {
    // Map<String, dynamic> json = document.data() as Map<String, dynamic>;
    List<dynamic>? shoesJson = json['shoes']; // Assuming 'shoes' is the key for shoes data
    List<Shoes> shoesList = shoesJson != null
        ? shoesJson.map((shoeJson) => Shoes.fromJson(shoeJson)).toList()
        : [];
    return Cart(
      userId: json[userDocId],
      shoes: shoesList,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>>? shoesJsonList =
    shoes?.map((shoe) => shoe.toJson()).toList();
    print("shoesJsonList: $shoesJsonList");
    return {
      userDocId: userId,
      'shoes': shoesJsonList,
    };
  }
}
