import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:shoe_xpert/widgets/buttons.dart';

import '../widgets/toasty.dart';

class AddNewCardScreen extends StatefulWidget {
  static const String route = "add_card_screen";

  const AddNewCardScreen({Key? key}) : super(key: key);

  @override
  State<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {
  String cardNumber = '4242 4242 4242 4242';
  String cardHolderName = '';
  String expiry = '';
  String cvv = '';

  bool isLoading = false;
  bool isCvvFocused = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController cardNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cardNumberController.text = cardNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Add Card'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      CreditCardWidget(
                        cardNumber: cardNumber,
                        height: 200,
                        width: 330,
                        expiryDate: expiry,
                        cardHolderName: cardHolderName,
                        cvvCode: cvv,
                        isHolderNameVisible: true,
                        showBackView: isCvvFocused,
                        onCreditCardWidgetChange: (creditCardBrand) {},
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        controller: cardNumberController,
                        inputFormatters: [
                          MaskedTextInputFormatter(
                              mask: 'xxxx xxxx xxxx xxxx', separator: ' '),
                          // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          } else if (value.length < 16) {
                            return 'Enter valid card number';
                          } else if (value.contains(',') ||
                              value.contains('.')) {
                            return 'Enter valid card number';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Card Number',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value.contains(',') || value.contains('.')) {
                            Toasty.error(
                                "characters are not allowed in card number.");
                            cardNumberController.clear();
                            return;
                          }
                          setState(() => cardNumber = value.trim());
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Card Holder Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() => cardHolderName = value.trim());
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Expiry Date (MM/YY)',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          MaskedTextInputFormatter(
                              mask: 'xx/xx', separator: '/')
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          // print("exp date: $value");
                          if (value == null || value.isEmpty) {
                            return 'Please enter card expiry';
                          }
                          var expDteLst = value.split('/');
                          if (int.parse(expDteLst[0]) > 12 ||
                              int.parse(expDteLst[0]) <= 0) {
                            return 'Invalid expiry month';
                          }

                          if ((int.parse(expDteLst[1]) + 2000) <=
                              DateTime.now().year - 1) {
                            return 'Invalid expiry year';
                          }
                          if ((int.parse(expDteLst[1]) + 2000) ==
                              DateTime.now().year) {
                            if (int.parse(expDteLst[0]) <
                                DateTime.now().month + 1) {
                              return 'Invalid expiry month';
                            }
                          }
                          if (value.length < 4) {
                            return 'Invalid date';
                          }
                          if (value.contains('.') ||
                              value.contains('-') ||
                              value.contains(',')) {
                            return 'Invalid card expiry date';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() => expiry = value.trim());
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Security Code (CVV)',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          MaskedTextInputFormatter(mask: 'xxxx', separator: '')
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.length < 3) {
                            return 'Enter valid CVV';
                          } else if (value.contains('.') ||
                              value.contains('-') ||
                              value.contains(',')) {
                            return 'Enter valid CVV';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {
                          setState(() => cvv = value.trim());
                        },
                      ),
                      const SizedBox(height: 25),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              width: double.infinity,
                              child: MyButton(
                                text: 'Add Card',
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    //   cardNumber,
                                    // cardHolderName,
                                    // expiry.split('/')[0],
                                    // expiry.split('/')[1],
                                    // cvv

                                    if (mounted) {
                                      Navigator.of(context).pop(true);
                                    }
                                  }
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newValueString = newValue.text;
    String valueToReturn = '';

    for (int i = 0; i < newValueString.length; i++) {
      if (newValueString[i] != '/') valueToReturn += newValueString[i];
      var nonZeroIndex = i + 1;
      final contains = valueToReturn.contains(RegExp(r'\/'));
      if (nonZeroIndex % 2 == 0 &&
          nonZeroIndex != newValueString.length &&
          !(contains)) {
        valueToReturn += '/';
      }
    }
    return newValue.copyWith(
      text: valueToReturn,
      selection: TextSelection.fromPosition(
        TextPosition(offset: valueToReturn.length),
      ),
    );
  }
}

class MaskedAccountTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;
  final RegExp nonNumericRegex = RegExp(r'[^0-9]');

  MaskedAccountTextInputFormatter(
      {required this.mask, required this.separator});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String maskedText = '';
    int maskIndex = 0;
    int valueIndex = 0;

    while (maskIndex < mask.length && valueIndex < newValue.text.length) {
      if (mask[maskIndex] == 'x') {
        // Replace 'x' with a numeric character
        maskedText += newValue.text[valueIndex];
        valueIndex++;
      } else {
        // Keep the separator character from the mask
        maskedText += mask[maskIndex];
      }
      maskIndex++;
    }

    // Remove non-numeric characters from the masked text
    maskedText = maskedText.replaceAll(nonNumericRegex, '');

    return TextEditingValue(
      text: maskedText,
      selection: TextSelection.collapsed(offset: maskedText.length),
    );
  }
}

class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter({
    required this.mask,
    required this.separator,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length > mask.length) return oldValue;
        if (newValue.text.length < mask.length &&
            mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text:
                '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}
