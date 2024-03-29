import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ShowProfilePic extends StatefulWidget {
  final String photoURL;
  ShowProfilePic(this.photoURL);
  @override
  _ShowProfilePicState createState() => _ShowProfilePicState();
}

class _ShowProfilePicState extends State<ShowProfilePic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Profile Photo',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Hero(
          tag: 'image',
          child: CachedNetworkImage(
              imageUrl: widget.photoURL,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.person)),
        ),
      ),
    );
  }
}
