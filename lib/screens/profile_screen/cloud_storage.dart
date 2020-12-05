import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/change_item.dart';
import 'package:provider/provider.dart';

class CloudStorageService {
  GlobalKey<ScaffoldState> key;
  BuildContext context;
  CloudStorageService(this.key, this.context);
  Future uploadProfilePic(File uploadImage) async {
    final uid = FirebaseAuth.instance.currentUser.uid;
    final storageReference =
        FirebaseStorage.instance.ref().child('pictures').child(uid);
    Provider.of<ChangeButtonNavigationBarIndex>(context, listen: false)
        .updateShowProfilePicChangeLoader(true);

    try {
      UploadTask _uploadTask = storageReference.putFile(uploadImage);
      _uploadTask.timeout(Duration(seconds: 40), onTimeout: () async {
        Provider.of<ChangeButtonNavigationBarIndex>(context, listen: false)
            .updateShowProfilePicChangeLoader(false);
        key.currentState.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[900],
            content: Text(
              'Failed to save profile image. Try again',
              style: TextStyle(fontSize: 18),
            ),
            duration: Duration(seconds: 2),
          ),
        );
        await _uploadTask.cancel();
        return _uploadTask.snapshot;
      });
      TaskSnapshot snapshot = await _uploadTask;
      if (snapshot != null) {
        if (snapshot.state == TaskState.success) {
          String url = await snapshot.ref.getDownloadURL();
          await FirebaseDatabase.instance
              .reference()
              .child('users')
              .child(uid)
              .update({'pictureURL': url});
          Provider.of<ChangeButtonNavigationBarIndex>(context, listen: false)
              .updateShowProfilePicChangeLoader(false);
        }
        if (snapshot.state == TaskState.error) {
          Provider.of<ChangeButtonNavigationBarIndex>(context, listen: false)
              .updateShowProfilePicChangeLoader(false);
          key.currentState.showSnackBar(
            SnackBar(
              backgroundColor: Colors.red[900],
              content: Text(
                'Failed to save profile image. Try again',
                style: TextStyle(fontSize: 18),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } on FirebaseException catch (e) {
      print(e);
      Provider.of<ChangeButtonNavigationBarIndex>(context, listen: false)
          .updateShowProfilePicChangeLoader(false);
      key.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[900],
          content: Text(
            'Failed to save profile image. Try again',
            style: TextStyle(fontSize: 18),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class PickProfileImage {
  GlobalKey<ScaffoldState> key;
  BuildContext context;
  PickProfileImage(this.key, this.context);
  Future pickImage() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      File file = File(result.files.single.path);
      CropProfileImage(key, context).cropImage(file.path);
    }
  }
}

class CropProfileImage {
  GlobalKey<ScaffoldState> key;

  BuildContext context;
  CropProfileImage(this.key, this.context);
  Future cropImage(String path) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        androidUiSettings: AndroidUiSettings(hideBottomControls: true));
    if (croppedFile != null)
      CloudStorageService(key, context).uploadProfilePic(croppedFile);
  }
}
