import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:kiakia/login_signup/decoration2.dart';
import 'package:kiakia/login_signup/services/authentication.dart';
import 'package:kiakia/login_signup/services/change_user_number.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/change_item.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/order.dart';
import 'package:kiakia/screens/order_screen/address_suggestion.dart';
import 'package:kiakia/screens/profile_screen/cloud_storage.dart';
import 'package:kiakia/screens/profile_screen/show_profile_pic.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Profile extends StatefulWidget {
  final String photoURL;
  final Map details;
  Profile(this.photoURL, this.details);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = new LocalStorage('user_data.json');
  String name, number, email, verificationStatus, address, provider;
  Map<String, dynamic> location;
  static final String key = 'AIzaSyDuc6Wz_ssKWEiNA4xJyUzT812LZgxnVUc';

  //the function that gets the user data from the local storage
  _getUserDataFromDevice() async {
    await storage.ready;
    location = await storage.getItem('location');
    Map user = await storage.getItem('userData');
    if (location != null) {
      address = location['address'];
    }
    if (user != null) {
      provider = user['provider'];
    }
    setState(() {});
  }

  saveAddressToDevice({address, lat, lng}) async {
    Map<String, dynamic> location = new Map();
    location['address'] = address;
    location['lat'] = lat;
    location['lng'] = lng;
    await storage.setItem('location', location);
  }

  Future convertPlaceIdToLatLng(data, String sessionToken) async {
    try {
      final response = await get(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=${data.placeId}&fields=geometry&key=$key&sessiontoken=$sessionToken');
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          saveAddressToDevice(
              address: data.description,
              lat: result['result']['geometry']['location']['lat'],
              lng: result['result']['geometry']['location']['lng']);
          _getUserDataFromDevice();
        }
      }
    } catch (e) {
      convertPlaceIdToLatLng(data, sessionToken);
    }
  }

  @override
  void initState() {
    _getUserDataFromDevice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool showLoader = Provider.of<ChangeButtonNavigationBarIndex>(context)
        .showProfilePicChangeLoader;
    if (widget.details != null) {
      name = widget.details['name'];
      number = widget.details['number'];
      verificationStatus =
          widget.details['isNumberVerified'] ? '' : 'not verified';
      email = widget.details['email'];
    }
    return Scaffold(
      key: _scaffoldKey,
      body: widget.details == null
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: LayoutBuilder(
                  builder: (context, viewPort) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: viewPort.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: widget.details == null
                                    ? Container(
                                        color: Color.fromRGBO(77, 172, 246, 1),
                                      )
                                    : Column(
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            alignment: Alignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 60,
                                                child:
                                                    widget.photoURL == null ||
                                                            widget.photoURL ==
                                                                ''
                                                        ? Center(
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 55,
                                                            ),
                                                          )
                                                        : InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            onTap: widget.photoURL !=
                                                                        null &&
                                                                    widget.photoURL !=
                                                                        ''
                                                                ? () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ShowProfilePic(widget.photoURL)));
                                                                  }
                                                                : null,
                                                            child: Hero(
                                                                tag: 'image',
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              60),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                          imageUrl: widget
                                                                              .photoURL,
                                                                          placeholder: (context, url) => CircleAvatar(
                                                                              radius:
                                                                                  60,
                                                                              backgroundColor: Colors.blue[
                                                                                  100],
                                                                              child:
                                                                                  CircularProgressIndicator()),
                                                                          errorWidget: (context,
                                                                              url,
                                                                              error) {
                                                                            return CircleAvatar(
                                                                              radius: 60,
                                                                              child: Icon(Icons.person, size: 60),
                                                                            );
                                                                          }),
                                                                )),
                                                          ),
                                                backgroundColor:
                                                    widget.photoURL == null ||
                                                            widget.photoURL ==
                                                                ''
                                                        ? Colors.blue[100]
                                                        : Colors.white,
                                              ),
                                              if (showLoader == false)
                                                Positioned(
                                                  bottom: -5,
                                                  right: -20,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.blue[300],
                                                        shape: BoxShape.circle),
                                                    child: IconButton(
                                                        icon: Icon(
                                                          Icons
                                                              .photo_camera_rounded,
                                                          size: 30,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          PickProfileImage(
                                                                  context)
                                                              .pickImage();
                                                        }),
                                                  ),
                                                ),
                                              if (showLoader)
                                                CircularProgressIndicator()
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 20),
                                          )
                                        ],
                                      ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                    border: BorderDirectional(
                                        bottom: BorderSide(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .color
                                                .withOpacity(0.75)))),
                                child: Text(email),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                    border: BorderDirectional(
                                        bottom: BorderSide(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .color
                                                .withOpacity(0.75)))),
                                child: Row(
                                  children: [
                                    number != null && number.isNotEmpty
                                        ? Expanded(
                                            child: Row(
                                              children: [
                                                Text('0' + number.substring(4)),
                                                SizedBox(width: 5),
                                                if (verificationStatus != '')
                                                  Expanded(
                                                    child: MaterialButton(
                                                        elevation: 0,
                                                        splashColor:
                                                            Colors.transparent,
                                                        onPressed: () async {
                                                          try {
                                                            final response =
                                                                await get(
                                                                    'https://www.google.com');
                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              await AuthenticationService()
                                                                  .verifyNumber(
                                                                      number:
                                                                          number,
                                                                      myContext:
                                                                          context);
                                                            }
                                                          } catch (e) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                              backgroundColor:
                                                                  Colors
                                                                      .red[900],
                                                              content: Text(
                                                                'Failed to verify number',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                            ));
                                                          }
                                                        },
                                                        child: Text(
                                                          '(click to verify number)',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue),
                                                        )),
                                                  )
                                              ],
                                            ),
                                          )
                                        : Expanded(
                                            child: Text(
                                                'No number attached to this account',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                    IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          changeUserNumber(
                                              context, 'Enter new number');
                                        })
                                  ],
                                ),
                              ),
                              if (address != null)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                      border: BorderDirectional(
                                          bottom: BorderSide(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .color
                                                  .withOpacity(0.75)))),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(address)),
                                      IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () async {
                                            final sessionToken = Uuid().v4();
                                            final AddressSuggestion result =
                                                await showSearch(
                                                    context: context,
                                                    query: address,
                                                    delegate: AddressSearch(
                                                        sessionToken));
                                            print(result.description);
                                            if (result != null) {
                                              convertPlaceIdToLatLng(
                                                  result, sessionToken);
                                            }
                                          })
                                    ],
                                  ),
                                ),
                              if (provider != null && provider == 'email')
                                InkWell(
                                  onTap: () {
                                    reAuthenticateUser(
                                        context, _scaffoldKey, email);
                                  },
                                  splashColor: Colors.transparent,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    decoration: BoxDecoration(
                                        border: BorderDirectional(
                                            bottom: BorderSide(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .color
                                                    .withOpacity(0.75)))),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Change Password',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        Spacer(),
                                        Icon(Icons.arrow_forward_ios,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .color
                                                .withOpacity(0.75))
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

Future<void> changeUserPassword(
    BuildContext myContext, GlobalKey<ScaffoldState> key) {
  String password, error;
  bool _hidePassword = true;
  final _changePasswordFormKey = GlobalKey<FormState>();
  bool showError = false, showLoader = false;
  final secureStorage = new FlutterSecureStorage();
  return showDialog<void>(
      context: myContext,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter new password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Form(
                          key: _changePasswordFormKey,
                          child: TextFormField(
                            onChanged: (val) {
                              password = val;
                              setState(() {
                                showError = false;
                              });
                            },
                            validator: (val) {
                              if (val.trim().isEmpty)
                                return 'Password cannot be empty';
                              else if (val.trim().length < 5)
                                return 'Password must be more than 5 characters';
                              else
                                return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            toolbarOptions: ToolbarOptions(
                                copy: false, cut: false, paste: true),
                            style: TextStyle(
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: _hidePassword
                                    ? Color.fromRGBO(15, 125, 188, 1)
                                    : Color.fromRGBO(0, 0, 0, 1)),
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: decoration2.copyWith(
                              hintText: 'New Password',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye,
                                    color: _hidePassword
                                        ? Color.fromRGBO(179, 179, 182, 1)
                                        : Color.fromRGBO(15, 125, 188, 1)),
                                onPressed: () {
                                  setState(() {
                                    _hidePassword = !_hidePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _hidePassword,
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      if (showError)
                        Center(
                          child: Text(
                            error,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 16),
                              )),
                          Spacer(),
                          MaterialButton(
                              elevation: 0,
                              textColor: Colors.blue,
                              onPressed: showLoader
                                  ? null
                                  : () async {
                                      setState(() {
                                        showError = false;
                                      });
                                      if (_changePasswordFormKey.currentState
                                          .validate()) {
                                        setState(() {
                                          showLoader = true;
                                        });
                                        try {
                                          await FirebaseAuth
                                              .instance.currentUser
                                              .updatePassword(password);
                                          Navigator.pop(context);
                                          await secureStorage.write(
                                              key: 'password', value: password);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Password successfully updated',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } on FirebaseException catch (e) {
                                          print(e);
                                          if (e.code == 'weak password')
                                            setState(() {
                                              showLoader = false;
                                              showError = true;
                                              error = 'Password too weak';
                                            });
                                          else if (e.code ==
                                              'network-request-failed')
                                            setState(() {
                                              showLoader = false;
                                              showError = true;
                                              error = 'Network request failed';
                                            });
                                          else if (e.code ==
                                              'too-many-requests')
                                            setState(() {
                                              showLoader = false;
                                              showError = true;
                                              error =
                                                  'Too many unsuccessful attempts. Try again later';
                                            });
                                          else
                                            setState(() {
                                              showLoader = false;
                                              showError = true;
                                              error =
                                                  'An error occurred. Try again';
                                            });
                                        }
                                      }
                                    },
                              child: showLoader
                                  ? SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator())
                                  : Text(
                                      'Done',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      });
}

Future<void> reAuthenticateUser(
    BuildContext myContext, GlobalKey<ScaffoldState> key, email) {
  String password, error;
  bool _hidePassword = true;
  final _changePasswordFormKey = GlobalKey<FormState>();
  bool showError = false, showLoader = false;
  return showDialog<void>(
      context: myContext,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter old password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Form(
                          key: _changePasswordFormKey,
                          child: TextFormField(
                            onChanged: (val) {
                              password = val;
                              setState(() {
                                showError = false;
                              });
                            },
                            validator: (val) {
                              if (val.trim().isEmpty)
                                return 'Password cannot be empty';
                              else
                                return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            toolbarOptions: ToolbarOptions(
                                copy: false, cut: false, paste: true),
                            style: TextStyle(
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: _hidePassword
                                    ? Color.fromRGBO(15, 125, 188, 1)
                                    : Color.fromRGBO(0, 0, 0, 1)),
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: decoration2.copyWith(
                              hintText: 'Old Password',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye,
                                    color: _hidePassword
                                        ? Color.fromRGBO(179, 179, 182, 1)
                                        : Color.fromRGBO(15, 125, 188, 1)),
                                onPressed: () {
                                  setState(() {
                                    _hidePassword = !_hidePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _hidePassword,
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      if (showError)
                        Center(
                          child: Text(
                            error,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 16),
                              )),
                          Spacer(),
                          MaterialButton(
                              elevation: 0,
                              textColor: Colors.blue,
                              onPressed: showLoader
                                  ? null
                                  : () async {
                                      setState(() {
                                        showError = false;
                                      });
                                      if (_changePasswordFormKey.currentState
                                          .validate()) {
                                        setState(() {
                                          showLoader = true;
                                        });
                                        try {
                                          await FirebaseAuth
                                              .instance.currentUser
                                              .reauthenticateWithCredential(
                                            EmailAuthProvider.credential(
                                                email: email,
                                                password: password),
                                          );
                                          Navigator.pop(context);
                                          changeUserPassword(myContext, key);
                                        } on FirebaseException catch (e) {
                                          print(e);
                                          if (e.code == 'wrong-password')
                                            setState(() {
                                              showLoader = false;
                                              showError = true;
                                              error = 'Incorrect password';
                                            });
                                          else if (e.code ==
                                              'network-request-failed')
                                            setState(() {
                                              showLoader = false;
                                              showError = true;
                                              error = 'Network request failed';
                                            });
                                          else if (e.code ==
                                              'too-many-requests')
                                            setState(() {
                                              showLoader = false;
                                              showError = true;
                                              error =
                                                  'Too many unsuccessful attempts. Try again later';
                                            });
                                          else
                                            setState(() {
                                              showLoader = false;
                                              showError = true;
                                              error = 'An error occurred';
                                            });
                                        }
                                      }
                                    },
                              child: showLoader
                                  ? SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator())
                                  : Text(
                                      'Done',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      });
}
