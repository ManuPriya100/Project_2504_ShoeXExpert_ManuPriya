import 'package:flutter/material.dart';
import 'package:shoe_xpert/models/user.dart';

import 'models/orders.dart';
import 'models/shoes.dart';

// ************* Useful Data *****************
const String userCollection = "UserCollection";
const String adminCollection = "AdminCollection";
const String shoesCollection = "ShoesCollection";
const String cartCollection = "CartCollection";
const String orderCollection = "OrderCollection";


const String imagePath = "images/";
const String userDocId = "docId";
const String username = "name";
const String userEmail = "email";
const String userPassword = "password";

UserModel? loggedInUser;

enum UserRole { user, admin }

UserRole selectedUserRole = UserRole.admin;


//************ Colors **************
Color pink = Colors.pink;
