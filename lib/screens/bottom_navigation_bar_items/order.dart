import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:kiakia/screens/order_screen/address_suggestion.dart';
import 'package:kiakia/screens/order_screen/order_details.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uuid/uuid.dart';

class Order extends StatefulWidget {
  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  Map<String, Map> packageDetails = {};
  TextEditingController _controller = new TextEditingController();
  Map location = {};
  static final String key = 'AIzaSyDuc6Wz_ssKWEiNA4xJyUzT812LZgxnVUc';
  final storage = new LocalStorage('user_data.json');
  bool isVerified = false, showLoader = false;
  String number;

  //gets the location of the user if any has been saved
  getLocationFromStorage() async {
    await storage.ready;
    Map storedLocation = await storage.getItem('location');
    if (storedLocation != null && storedLocation.isNotEmpty && _controller.text.isEmpty) {
      location = storedLocation;
      _controller.text = location['address'];
    }

    //this gets the user information from the local storage
    Map data = await storage.getItem('userData');
    isVerified = data['status'];
    number = data['number'];
  }

  removeItemsFromMap(String key) {
    packageDetails.remove(key);
  }

  addItemsToMap(String key, dynamic value) {
    packageDetails.putIfAbsent(key, () => value);
  }

  Future convertPlaceIdToLatLng(data, String sessionToken) async {
    Map locationLatLng = {};
    try {
      final response = await get(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=${data.placeId}&fields=geometry&key=$key&sessiontoken=$sessionToken');
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          locationLatLng.putIfAbsent(
              'lat', () => result['result']['geometry']['location']['lat']);
          locationLatLng.putIfAbsent(
              'lng', () => result['result']['geometry']['location']['lng']);
          location = locationLatLng;
        }
        location.putIfAbsent('address', () => data.description);
      }
      if (showLoader) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderDetails(packageDetails, location)));
        setState(() {
          showLoader = false;
        });
      }
    } catch (e) {
      convertPlaceIdToLatLng(data, sessionToken);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {});
    getLocationFromStorage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: ListView(
        children: [
          Text(
            'Cylinder Size',
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          SizedBox(height: 8),
          Column(
            children: [
              Row(
                children: [
                  GasPackages(
                    width: width,
                    price: 900,
                    packageName: 'Mini Package',
                    packageSize: '3kg',
                    addItem: addItemsToMap,
                    removeItem: removeItemsFromMap,
                  ),
                  Spacer(),
                  GasPackages(
                    width: width,
                    packageSize: '6kg',
                    packageName: 'Light Package',
                    price: 1800,
                    addItem: addItemsToMap,
                    removeItem: removeItemsFromMap,
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  GasPackages(
                    width: width,
                    price: 3750,
                    packageName: 'Standard Package',
                    packageSize: '12.5kg',
                    addItem: addItemsToMap,
                    removeItem: removeItemsFromMap,
                  ),
                  Spacer(),
                  GasPackages(
                    width: width,
                    packageSize: '50kg',
                    packageName: 'Business Package',
                    price: 9000,
                    addItem: addItemsToMap,
                    removeItem: removeItemsFromMap,
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Location',
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          SizedBox(height: 8),
          Container(
            width: width,
            padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
            decoration: BoxDecoration(
                color: Theme.of(context).buttonColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter destination address below',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: 15),
                TextField(
                  readOnly: true,
                  controller: _controller,
                  style: TextStyle(height: 1.5, fontSize: 16),
                  onTap: () async {
                    final sessionToken = Uuid().v4();
                    final AddressSuggestion result = await showSearch(
                        context: context,
                        query: _controller.text,
                        delegate: AddressSearch(sessionToken));
                    if (result != null) {
                      location = {};
                      _controller.text = result.description;
                      await convertPlaceIdToLatLng(result, sessionToken);
                    }
                  },
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color.fromRGBO(55, 137, 236, 1),
                      ),
                      hintText: 'Search delivery location',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          height: 1.5,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .color
                              .withOpacity(0.4))),
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          FlatButton(
            height: 45,
            onPressed: () async {
              await getLocationFromStorage();
              if (number == null || number == '') {
                setState(() {
                  showLoader = false;
                });
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red[900],
                    content: Text(
                      'No number registered with account. Please register a number to Order',
                      style: TextStyle(fontSize: 18),
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );
              } else if (isVerified == false) {
                setState(() {
                  showLoader = false;
                });
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red[900],
                    content: Text(
                      'Number not verified, please verify your number to Order',
                      style: TextStyle(fontSize: 18),
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );
              } else if (packageDetails == null || packageDetails.isEmpty) {
                setState(() {
                  showLoader = false;
                });
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red[900],
                    content: Text(
                      'Please select a package from cylinder size',
                      style: TextStyle(fontSize: 18),
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if ((_controller.text != null &&
                      _controller.text.trim().isNotEmpty) &&
                  (location['lat'] == null || location['lat'] == '')) {
                setState(() {
                  showLoader = true;
                });
              } else if (_controller.text == null || _controller.text.isEmpty) {
                setState(() {
                  showLoader = false;
                });
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red[900],
                    content: Text(
                      'Please input destination address',
                      style: TextStyle(fontSize: 18),
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            OrderDetails(packageDetails, location)));
                setState(() {
                  showLoader = false;
                });
              }
            },
            child: showLoader
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  )
                : Text(
                    'Next',
                    style: Theme.of(context).textTheme.button,
                  ),
            color: Theme.of(context).buttonColor,
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

//creates the container that contains the gas sizes and their packages
class GasPackages extends StatefulWidget {
  final String packageName, packageSize;
  final double width, price;
  final Function removeItem, addItem;

  const GasPackages(
      {this.packageName,
      this.packageSize,
      this.width,
      this.price,
      this.addItem,
      this.removeItem});
  @override
  _GasPackagesState createState() => _GasPackagesState();
}

class _GasPackagesState extends State<GasPackages> {
  bool selected = false;
  TextEditingController _controller = new TextEditingController(text: '1');
  final formatCurrency =
      new NumberFormat.currency(locale: 'en_US', symbol: '#');
  Map<String, String> details = {'quantity': '1', 'amount': '1', 'size': ''};

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    details['size'] = widget.packageSize;
    return InkWell(
      onTap: () {
        details['quantity'] = _controller.text;
        details['amount'] =
            (widget.price * double.parse(details['quantity']))
                .toString();
        setState(() {
          selected = !selected;
        });
        if (selected) {
          widget.addItem(widget.packageName, details);
        } else {
          widget.removeItem(widget.packageName);
        }
      },
      splashColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(10),
        width: (widget.width - 40) / 2 - 10,
        decoration: BoxDecoration(
            color: Theme.of(context).buttonColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              alignment: Alignment.center,
              child: Image.asset(
                'assets/gas_cylinder3.jpg',
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              widget.packageName,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.packageSize,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 16, fontWeight: FontWeight.w300),
                ),
                SizedBox(width: 5),
                Text('x'),
                SizedBox(width: 8),
                Container(
                  height: 25,
                  width: 25,
                  color: Colors.white,
                  child: TextField(
                    controller: _controller,
                    decoration: null,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    style: TextStyle(height: 1.5),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (val) {
                      if (val.trim().isNotEmpty) details['quantity'] = val;
                      if (val.trim().isEmpty || int.parse(val.trim()) == 0)
                        details['quantity'] = '1';
                      if (val.trim().length == 2)
                        FocusScope.of(context).focusedChild.unfocus();
                      details['amount'] =
                          (widget.price * double.parse(details['quantity']))
                              .toString();
                      if (selected) {
                        widget.removeItem(widget.packageName);
                        widget.addItem(widget.packageName, details);
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                RichText(
                    text: TextSpan(
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(fontSize: 14),
                        children: [
                      TextSpan(text: '\u{20A6} ', style: TextStyle(fontSize: 12)),
                      TextSpan(
                        text:
                            '${formatCurrency.format(widget.price * double.parse(details['quantity'])).toString().substring(1)}',
                      ),
                    ])),
                Spacer(),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child:
                      selected ? Icon(Icons.check, color: Colors.blue) : null,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

//builds the page where the user location is entered
class AddressSearch extends SearchDelegate<AddressSuggestion> {
  final String sessionToken;
  AddressSearch(this.sessionToken);
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return locationSuggestion();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return locationSuggestion();
  }

  Widget locationSuggestion() {
    return FutureBuilder(
      future: AddressSuggestionRequest(sessionToken).fetchAddress(query),
      builder: (context, AsyncSnapshot<List<AddressSuggestion>> snapshot) {
        return query == ''
            ? Container(
                padding: EdgeInsets.all(20),
                child: Text('Enter your address'),
              )
            : snapshot.hasData
                ? ListView.builder(
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.fromLTRB(10, 5, 20, 0),
                        tileColor: index % 2 == 0
                            ? Color.fromRGBO(81, 83, 82, 0.3)
                            : Color.fromRGBO(81, 83, 82, 0.1),
                        leading: Icon(Icons.location_on_outlined),
                        title: Text(snapshot.data[index].description),
                        onTap: () {
                          close(context, snapshot.data[index]);
                        },
                      );
                    },
                    itemCount: snapshot.data.length,
                  )
                : Container(
                    padding: EdgeInsets.all(16),
                    child: Text('Loading...'),
                  );
      },
    );
  }
}
