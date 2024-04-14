import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoe_xpert/constants.dart';

class Shoes {
  String? docId;
  String? name;
  String? image;
  int? price;
  String? color;
  int? size;

  Shoes({this.docId, this.name, this.image, this.price, this.color, this.size,});

  factory Shoes.fromQueryDocument(QueryDocumentSnapshot mp) {
    Map json = mp.data() as Map;
    return Shoes(
      name: json['name'],
      image: json['image'],
      price: json['price'],
      color: json['color'],
      size: json['size'],
      docId: mp.id,
    );
  }


  factory Shoes.fromJson( Map json) {
    return Shoes(
      name: json['name'],
      image: json['image'],
      price: json['price'],
      color: json['color'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'price': price,
      'color': color,
      'size': size,
    };
  }
}
