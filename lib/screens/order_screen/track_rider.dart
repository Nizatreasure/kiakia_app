import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kiakia/screens/order_screen/distance.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackRider extends StatefulWidget {
  @override
  _TrackRiderState createState() => _TrackRiderState();
}

class _TrackRiderState extends State<TrackRider>
    with AutomaticKeepAliveClientMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String phoneNumber = '+2348117933576';
  Completer<GoogleMapController> _mapController = Completer();
  double _originLatitude = 9.0611743, _originLongitude = 7.4894103;
  double _destinationLatitude = 9.539399, _destinationLongitude = 6.468836;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polyLines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  String googleApiKey = 'AIzaSyDuc6Wz_ssKWEiNA4xJyUzT812LZgxnVUc';
  String url =
      'https://maps.googleapis.com/maps/api/distancematrix/json?origins=';
  bool _serviceEnabled = true;
  LocationPermission _permissionGranted;
  Position currentPosition;
  CameraPosition initialCameraPosition;
  StreamSubscription<Position> positionStream;
  String distance = '', time = '', originAddress = '';
  String error;

  _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);

    _addMarker(
        id: 'Minna',
        position: LatLng(currentPosition.latitude, currentPosition.longitude),
        descriptor:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));

    _addMarker(
        id: 'Munch Box',
        position: LatLng(_destinationLatitude, _destinationLongitude),
        descriptor:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
    _getPolyline();
  }

  _addMarker({String id, BitmapDescriptor descriptor, LatLng position}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
    );
    markers[markerId] = marker;
  }

  _addPolyline(
    String id,
  ) {
    PolylineId polylineId = PolylineId(id);
    polyLines = {};
    Polyline polyline = Polyline(
        polylineId: polylineId,
        points: polylineCoordinates,
        color: Colors.red,
        width: 7);
    polyLines[polylineId] = polyline;
    if (mounted) setState(() {});
  }

  //sets the time, distance and current location of the rider
  void setTimeDistance() async {
    if (currentPosition != null) {
      Distance myDistance = Distance(url +
          '${currentPosition.latitude},${currentPosition.longitude}&destinations=$_destinationLatitude, $_destinationLongitude&key=' +
          googleApiKey);
      await myDistance.getDistance();
      if (mounted) {
        setState(() {
          distance = myDistance.distance;
          time = myDistance.time;
          originAddress = myDistance.originAddress;
        });
      }
    }
  }

  //gets the coordinates between the origin and destination location that would be used to draw the polylines
  _getPolyline() async {
    if (mounted) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(currentPosition.latitude, currentPosition.longitude),
        PointLatLng(_destinationLatitude, _destinationLongitude),
        travelMode: TravelMode.driving,
      );

      //resets the polyline coordinates whenever the riders current location changes
      polylineCoordinates = [];
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
      _addPolyline('Poly');
    }
  }

  //requests for location permission from the users
  getLocationPermission() async {
    try {
      _serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (_serviceEnabled) {
        _permissionGranted = await Geolocator.checkPermission();
        if (_permissionGranted == LocationPermission.whileInUse ||
            _permissionGranted == LocationPermission.always) {
          currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          setState(() {});
          setTimeDistance();
          positionStream = Geolocator.getPositionStream(
                  desiredAccuracy: LocationAccuracy.high)
              .listen((Position position) {
            currentPosition = position;
            changeMarkerLocation();
            _getPolyline();
            setTimeDistance();
          });
        } else {
          if (mounted) {
            setState(() {});
            getLocationPermission();
          }
        }
      } else {
        if (mounted) {
          setState(() {});
          getLocationPermission();
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'LOCATION_SERVICES_DISABLED') {
        error = e.message;
      } else
        error = 'error';
    }
  }

  //updates the location pointer as the current location changes
  changeMarkerLocation() async {
    if (mounted) {
      final GoogleMapController controller = await _mapController.future;
      double zoomLevel = await controller.getZoomLevel();
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: zoomLevel)));

      controller.dispose();

      setState(() {
        markers.remove(MarkerId('Minna'));
        markers.putIfAbsent(
            MarkerId('Minna'),
            () => Marker(
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                  markerId: MarkerId('Minna'),
                  position: LatLng(
                      currentPosition.latitude, currentPosition.longitude),
                ));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
    getLocationPermission();
  }

  @override
  void dispose() {
    super.dispose();
    if (positionStream != null) {
      positionStream.cancel();
    }
  }

  launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    initialCameraPosition = currentPosition == null
        ? CameraPosition(
            target: LatLng(_originLatitude, _originLongitude), zoom: 17)
        : initialCameraPosition;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white30,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
          )
        ],
        backgroundColor: Color(0xffffffff),
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Order Details',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      endDrawer: Drawer(),
      body: trackRiderBody(),
    );
  }

//decides what to show base on the permission granted by the user
  Widget trackRiderBody() {
    if (_serviceEnabled) {
      switch (_permissionGranted) {
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          return currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    GoogleMap(
                      markers: Set<Marker>.of(markers.values),
                      myLocationEnabled: true,
                      polylines: Set<Polyline>.of(polyLines.values),
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: initialCameraPosition,
                    ),
                    distance == null || distance == ''
                        ? Container(
                            height: 0,
                            width: 0,
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            constraints:
                                BoxConstraints(maxHeight: 220, maxWidth: 400),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(77, 172, 246, 1),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Text(distance,
                                            style: TextStyle(fontSize: 18)),
                                        VerticalDivider(
                                          width: 20,
                                          color: Colors.black,
                                          thickness: 2,
                                        ),
                                        Text(
                                            time == 'Unknown'
                                                ? time
                                                : time + ' away',
                                            style: TextStyle(fontSize: 18))
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: AutoSizeText(
                                        originAddress,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                        maxLines: 5,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    contentPadding: EdgeInsets.only(left: 0),
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          ExactAssetImage('assets/niza.jpg'),
                                    ),
                                    onTap: () {
                                      launchURL('tel: $phoneNumber');
                                    },
                                    title: Text(
                                      'Undie Ebenezer',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    subtitle: Text(
                                      phoneNumber,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                    trailing: Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                );
        case LocationPermission.denied:
        case LocationPermission.deniedForever:
          return Align(
            alignment: Alignment(0, -0.5),
            child: Container(
              height: 130,
              width: 230,
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please grant this app location access to continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text('Go back',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w900,
                                fontSize: 16)),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () async {
                          if (_permissionGranted == LocationPermission.denied) {
                            _permissionGranted =
                                await Geolocator.requestPermission();
                            setState(() {});
                          } else {
                            await Geolocator.openAppSettings();
                          }
                        },
                        child: Text('Grant Access',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w900,
                                fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        default:
          return Container(
            color: Colors.white30,
          );
      }
    } else {
      return Align(
        alignment: Alignment(0, -0.5),
        child: Container(
          height: 130,
          width: 230,
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please turn on device location to continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Spacer(),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text('Go back',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () async {
                      await Geolocator.openLocationSettings();
                    },
                    child: Text('Open Settings',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
