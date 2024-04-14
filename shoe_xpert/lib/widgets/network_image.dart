import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

imageContainer(String path) {
  return Container(
    decoration: BoxDecoration(boxShadow: [
      BoxShadow(
        color: Color(0xffE1FFE7).withOpacity(0.3),
        blurRadius: 5,
        offset: Offset.zero,
      )
    ]),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: FadeTransition(
        opacity: AlwaysStoppedAnimation(1.0),
        child: Image.network(
          path, // Replace with the actual image URL

          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons
                .error); // Display an error icon if the image fails to load
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              // _handleImageLoaded();
              return child;
            }
            return CupertinoActivityIndicator(
              animating: true,
            );
          },
        ),
      ),
    ),

    // Image.network(path, errorBuilder: (context, error, stackTrace) {
    //   return Text(
    //     'Uploaded on ${path}',
    //     style: TextStyle(fontSize: 12, color: AppColors.white),
    //   );
    // }, fit: BoxFit.fill),
    // ),
  );
}
