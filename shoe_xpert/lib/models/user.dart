import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';

class UserModel {
  String? name,docId;
  String? email;
  String? password;

  UserModel({this.name, this.email, this.password, this.docId});

  factory UserModel.fromJson(QueryDocumentSnapshot json) {
    return UserModel(
      name: json.get(username),
      email: json.get(userEmail),
      password: json.get(userPassword),
      docId: json.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {userDocId:docId,username: name, userEmail: email,userPassword: password};
  }
}
