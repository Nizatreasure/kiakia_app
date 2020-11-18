import 'dart:convert';
import 'package:http/http.dart';

class AddressSuggestion {
  final String placeId, description;
  AddressSuggestion({this.description, this.placeId});
}

class AddressSuggestionRequest {
  final sessionToken;
  static final String key = 'AIzaSyDuc6Wz_ssKWEiNA4xJyUzT812LZgxnVUc';
  AddressSuggestionRequest(this.sessionToken);

  Future<List<AddressSuggestion>> fetchAddress(String input) async {
    List placesList = [];
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=en&components=country:ng&key=$key&sessiontoken=$sessionToken';
    try {
      final response = await get(request);
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          // create a list of the suggested places
          return result['predictions']
              .map<AddressSuggestion>((p) => AddressSuggestion(
                  placeId: p['place_id'], description: p['description']))
              .toList();
        }
        if (result['status'] == 'ZERO_RESULTS') {
          return [];
        }
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
