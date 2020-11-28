import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:kiakia/screens/order_screen/distance.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackRider extends StatefulWidget {
  final Map userLocation, rider;
  final String transactionID;
  TrackRider({this.rider, this.userLocation, this.transactionID});
  @override
  _TrackRiderState createState() => _TrackRiderState();
}

class _TrackRiderState extends State<TrackRider>
    with AutomaticKeepAliveClientMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polyLines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  String googleApiKey = 'AIzaSyDuc6Wz_ssKWEiNA4xJyUzT812LZgxnVUc';
  String url =
      'https://maps.googleapis.com/maps/api/distancematrix/json?origins=';

  CameraPosition initialCameraPosition;
  StreamSubscription riderLocationStream;
  String distance = '', time = '', originAddress = '';
  String error;

  _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);

    _addMarker(
        id: 'Rider Location',
        position: LatLng(widget.rider['lat'], widget.rider['lng']),
        descriptor:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        title: 'Rider\'s Location');

    _addMarker(
        id: 'Delivery Location',
        position:
            LatLng(widget.userLocation['lat'], widget.userLocation['lng']),
        descriptor:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        title: 'Delivery Location');
    _getPolyline(widget.rider['lat'], widget.rider['lng']);
  }

  _addMarker(
      {String id, BitmapDescriptor descriptor, LatLng position, String title}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
      infoWindow: InfoWindow(title: title),
    );
    markers[markerId] = marker;
  }

  _getRiderLocation() {
    riderLocationStream = FirebaseDatabase.instance
        .reference()
        .child('Transactions')
        .child(FirebaseAuth.instance.currentUser.uid)
        .child(widget.transactionID)
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (event != null) {
        setState(() {
          _getPolyline(data['lat'], data['lng']);
          changeMarkerLocation(data['lat'], data['lng']);
          setTimeDistance(data['lat'], data['lng']);
        });
      }
    });
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
  void setTimeDistance(lat, lng) async {
    if (lat != null) {
      Distance myDistance = Distance(url +
          '$lat,$lng&destinations=${widget.userLocation['lat']}, ${widget.userLocation['lng']}&key=' +
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
  _getPolyline(lat, lng) async {
    if (mounted) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(lat, lng),
        PointLatLng(widget.userLocation['lat'], widget.userLocation['lng']),
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

  //updates the location pointer as the current location changes
  changeMarkerLocation(lat, lng) async {
    if (mounted) {
      final GoogleMapController controller = await _mapController.future;
      double zoomLevel = await controller.getZoomLevel();
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: zoomLevel)));

      controller.dispose();

      setState(() {
        markers.remove(MarkerId('Rider Location'));
        markers.putIfAbsent(
            MarkerId('Rider Location'),
            () => Marker(
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                  markerId: MarkerId('Rider Location'),
                  position: LatLng(lat, lng),
                ));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
    setTimeDistance(widget.rider['lat'], widget.rider['lng']);
    _getRiderLocation();
  }

  @override
  void dispose() {
    super.dispose();
    if (riderLocationStream != null) riderLocationStream.cancel();
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
    initialCameraPosition = CameraPosition(
        target: LatLng(widget.rider['lat'], widget.rider['lng']), zoom: 12);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white30,
      appBar: AppBar(
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
          'Track Rider',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            markers: Set<Marker>.of(markers.values),
            myLocationEnabled: false,
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
                  constraints: BoxConstraints(maxHeight: 220, maxWidth: 400),
                  decoration: BoxDecoration(
                      color: Theme.of(context).buttonColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Row(
                            children: [
                              Text(distance, style: TextStyle(fontSize: 18)),
                              VerticalDivider(
                                width: 20,
                                color: Colors.black,
                                thickness: 2,
                              ),
                              Text(time == 'Unknown' ? time : time + ' away',
                                  style: TextStyle(fontSize: 18))
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            originAddress,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            maxLines: 5,
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.only(left: 20, right: 10),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage(widget.rider['pictureURL']),
                        ),
                        onTap: () {
                          launchURL('tel: ${widget.rider['number']}');
                        },
                        title: Text(
                          widget.rider['name'],
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          widget.rider['number'],
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        trailing: Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
