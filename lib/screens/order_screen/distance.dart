import 'dart:convert';

import 'package:http/http.dart';


class Distance  {
  final String url;

  Distance(this.url);

  String distance;
  String originAddress;
  String time;

  Future<void> getDistance () async {
   try{
     var response = await get(Uri.encodeFull(url));
     if (response.statusCode == 200) {
       var jsonResponse = jsonDecode(response.body);
       originAddress = jsonResponse['origin_addresses'][0];
       distance = jsonResponse['rows'][0]['elements'][0]['distance']['text'];
       time = jsonResponse['rows'][0]['elements'][0]['duration']['text'];
     }
   } catch (e) {
     time = 'Unknown';
     originAddress = 'Could not get Location';
     distance = 'Unknown';
   }
  }
}