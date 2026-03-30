// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pacervtu/src/model/datamodel.dart';
import 'package:pacervtu/src/utils/id_generator.dart';


class VtuService {
  final String baseUrl = "https://sandbox.vtpass.com/api";
  final String apiKey = "382b853d8cd5146813d9af24d2e10d16";      
  final String secretKey = "SK_168bad8d6ef3cb79a785326c4bada2cc4beaaf7c5cc";
  final String publicKey = "PK_592f54f33e4de418db47727e6dcb72b91097403a477";


Future<Map<String, dynamic>> buyAirtime({
  required String network,
  required int phone,
  required int amount,
}) async {
  final url = Uri.parse("$baseUrl/pay");

  final headers = {
    "Content-Type": "application/json",
    "api-key": apiKey,
    "secret-key": secretKey,
  };

  final body = jsonEncode({
    "request_id": LagosIdGenerator.generate(),
    "serviceID": network,
    "amount": amount,
    "phone": phone,
  });

  final response = await http.post(url, headers: headers, body: body);

  print("POST $url");
  print("Body: $body");
  print("Response: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data["code"] == "000") {
      return data;
    } else {
      throw Exception(data["response_description"] ?? "Transaction failed");
    }
  } else {
    throw Exception("Server error: ${response.statusCode}");
  }
}


Map<String, String> get headers => {
        "Content-Type": "application/json",
        "api-key": apiKey,
        "public-key": publicKey,
      };

Future<List<DataVariation>> getDataBundles(String serviceID) async {
    final response = await http.get(
      Uri.parse("$baseUrl/service-variations?serviceID=$serviceID"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if ((data["code"] == "000" || data["response_description"] != null) &&
          data["content"]?["variations"] != null) {
        final List variations = data["content"]["variations"];
        return variations
            .map((e) => DataVariation.fromJson(e))
            .toList();
      } else {
        throw Exception("No variations found or invalid response format");
      }
    } else {
      throw Exception("Failed to fetch bundles: ${response.body}");
    }
  }

  /// Purchase MTN data
Future<Map<String, dynamic>> buyData({
  required String serviceID,
  required String variationCode,
  required String phone,
  required String amount,
  required String requestId,
}) async {
  final payload = jsonEncode({
    "request_id": requestId,
    "serviceID": serviceID,
    "billersCode": phone,
    "variation_code": variationCode,
    "amount": amount,
    "phone": phone,
  });

  final response = await http.post(
    Uri.parse("$baseUrl/pay"),
    headers: {
      "api-key": apiKey,
      "secret-key": secretKey,
      "public-key": publicKey,
      "Content-Type": "application/json"
    },
    body: payload,
  );

  print(" BUY DATA RESPONSE: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception(
      "Data purchase failed: ${response.statusCode} ${response.body}",
    );
  }
}


  /// Query transaction status
  Future<Map<String, dynamic>> queryTransaction(String requestId) async {
    final payload = jsonEncode({"request_id": requestId});

    final response = await http.post(
      Uri.parse("$baseUrl/requery"),
      headers: headers,
      body: payload,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          "Transaction query failed: ${response.statusCode} ${response.body}");
    }
  }

Future<Map<String, dynamic>> payElectricityBill({
  required String serviceID,   
  required String meterNumber,   
  required double amount,
  required String meterType,    
}) async {
  final url = Uri.parse("$baseUrl/pay");

  final requestId = DateTime.now().millisecondsSinceEpoch.toString();

  final headers = {
    "api-key": apiKey,
    "secret-key": secretKey,
    "Content-Type": "application/json",
  };

  final body = jsonEncode({
    "request_id": requestId,
    "serviceID": serviceID,
    "billersCode": meterNumber,
    "variation_code": meterType,
    "amount": amount,
    "phone": "08100000000", // VTpass requires a phone even if unused
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Electricity bill payment failed: ${response.body}");
  }
}


Future<Map<String, dynamic>> verifyTvDecoder({
  required String serviceID, // dstv, gotv, startimes
  required String smartCardNumber,
}) async {
  final url = Uri.parse("https://vtpass.com/api/merchant-verify");

  final headers = {
    "api-key": apiKey,
    "secret-key": secretKey,
    "Content-Type": "application/json",
  };

  final body = jsonEncode({
    "serviceID": serviceID,
    "billersCode": smartCardNumber, 
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Decoder verification failed: ${response.body}");
  }
}


  Future<Map<String, dynamic>> getTvVariations(String serviceID) async {
    final url = Uri.parse("$baseUrl/tv/variations?serviceID=$serviceID");
    final headers = {
      "Authorization": "Bearer $apiKey",
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load TV variations: ${response.body}");
    }
  }

Future<Map<String, dynamic>> payTvSubscription({
  required String serviceID,
  required String smartCardNumber,
  required String variationCode,
  required double amount,
  required String phoneNumber,
}) async {
  final url = Uri.parse("$baseUrl/pay");

  final requestId = DateTime.now().millisecondsSinceEpoch.toString();

  final headers = {
    "api-key": apiKey,
    "secret-key": secretKey,
    "Content-Type": "application/json",
  };

  final body = jsonEncode({
    "request_id": requestId,
    "serviceID": serviceID,
    "billersCode": smartCardNumber,
    "variation_code": variationCode,
    "amount": amount,
    "phone": phoneNumber,
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception("TV subscription failed: ${response.body}");
  }
}

}
