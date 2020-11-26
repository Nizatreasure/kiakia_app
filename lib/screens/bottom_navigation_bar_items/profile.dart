import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kiakia/login_signup/services/change_user_number.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/change_item.dart';
import 'package:kiakia/screens/bottom_navigation_bar_items/order.dart';
import 'package:kiakia/screens/cloud_storage.dart';
import 'package:kiakia/screens/order_screen/address_suggestion.dart';
import 'package:kiakia/screens/show_profile_pic.dart';
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
  String name, number, email, verificationStatus, address;
  Map<String, dynamic> location;
  static final String key = 'AIzaSyDuc6Wz_ssKWEiNA4xJyUzT812LZgxnVUc';

  //the function that gets the user data from the local storage
  _getUserDataFromDevice() async {
    await storage.ready;
    location = await storage.getItem('location');
    if (location != null) {
      address = location['address'];
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
    name = widget.details['name'];
    number = widget.details['number'];
    verificationStatus =
        widget.details['isNumberVerified'] ? '' : 'not verified';
    email = widget.details['email'];
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
                                            alignment: Alignment.center,
                                            overflow: Overflow.visible,
                                            children: [
                                              CircleAvatar(
                                                radius: 60,
                                                child: widget.photoURL ==
                                                            null ||
                                                        widget.photoURL == ''
                                                    ? Center(
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 55,
                                                        ),
                                                      )
                                                    : InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        onTap: widget.photoURL !=
                                                                    null &&
                                                                widget.photoURL !=
                                                                    ''
                                                            ? () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ShowProfilePic(widget.photoURL)));
                                                              }
                                                            : null,
                                                        child: Hero(
                                                            tag: 'image',
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          60),
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: widget
                                                                    .photoURL,
                                                                placeholder: (context,
                                                                        url) =>
                                                                    CircleAvatar(
                                                                        radius:
                                                                            60,
                                                                        backgroundColor:
                                                                            Colors.blue[
                                                                                100],
                                                                        child:
                                                                            CircularProgressIndicator()),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .person),
                                                              ),
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
                                                                  _scaffoldKey,
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
                                            child: RichText(
                                                text: TextSpan(
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .copyWith(fontSize: 14),
                                                    children: [
                                                  TextSpan(
                                                      text: '0' +
                                                          number.substring(4)),
                                                  if (verificationStatus !=
                                                          null &&
                                                      verificationStatus != '')
                                                    TextSpan(text: '  ('),
                                                  if (verificationStatus !=
                                                          null &&
                                                      verificationStatus != '')
                                                    TextSpan(
                                                        text:
                                                            verificationStatus,
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  if (verificationStatus !=
                                                          null &&
                                                      verificationStatus != '')
                                                    TextSpan(text: ')')
                                                ])),
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
                              InkWell(
                                onTap: () {},
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
