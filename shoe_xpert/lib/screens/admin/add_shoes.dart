import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_xpert/constants.dart';
import 'package:shoe_xpert/main.dart';
import 'package:shoe_xpert/widgets/buttons.dart';

import '../../models/shoes.dart';
import '../../widgets/toasty.dart';

class AddShoes extends StatefulWidget {
  const AddShoes({super.key});

  @override
  State<AddShoes> createState() => _AddShoesState();
}

class _AddShoesState extends State<AddShoes> {
  final priceController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  File? shoeImage;

  @override
  void initState() {
    super.initState();
  }

  Future<String> addShoeImage(File image) async {
    try {
      // Extract image name from image cache url
      var pathimage = image.path; // Use path property instead of toString()
      print("pathimage: $pathimage");
      var temp = pathimage.lastIndexOf('/');
      var result = pathimage.substring(temp + 1); // Adjust the substring index
      print("result = $result");

      // Saving image in firebase storage
      final ref =
          FirebaseStorage.instance.ref().child('ShoesImages').child(result);
      var response1 = await ref.putFile(image);
      print("Updated $response1");
      var imageUrl = await ref.getDownloadURL();
      print("imageUrl $imageUrl");

      return imageUrl;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addNewShoeInDatabase() async {
    setState(() {
      isLoading = true;
    });
    String imgUrl = await addShoeImage(shoeImage!);
    print("imgUrl 2: $imgUrl");
    Shoes shoe = Shoes(
      name: nameController.text.trim(),
      image: imgUrl,
      price: int.parse(priceController.text.trim()),
    );
    print("shoe 2: ${shoe.name} , ${shoe.image}");

    fireStore.collection(shoesCollection).add(shoe.toJson()).then((_) async {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Shoes Added successfully",
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
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 18),
                  )),
            ],
          );
        },
      );
    }).catchError((error) {
      Toasty.success("Some error occurred. try again later");
      setState(() {
        isLoading = false;
      });

      print("Error: $error");
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        shoeImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text("Add New Shoes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 40),
                shoeImage != null
                    ? Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(shoeImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: _pickImage,
                        child: Container(
                          color: Colors.pink.withOpacity(0.3),
                          width: 300,
                          height: 200,
                          child: Center(
                              child: Icon(
                            Icons.image_outlined,
                            size: 25,
                          )),
                        ),
                      ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    hintText: "Enter name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter name" : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: "Price",
                      hintText: "Enter price",
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      // FilteringTextInputFormatter.allow(
                      //   RegExp(r'^\d+\.?\d{0,2}$'),
                      // ),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter Price";
                      } else {
                        return null;
                      }
                    }),
                SizedBox(height: 15),
                isLoading
                    ? CircularProgressIndicator(
                        color: Colors.purple,
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: MyButton(
                            onPressed: () {
                              if (shoeImage == null) {
                                Toasty.error("Please select shoes image");
                                return;
                              }
                              if (_formKey.currentState!.validate()) {
                                addNewShoeInDatabase();
                              }
                            },
                            text: "Add Shoes"),
                      ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
