import 'dart:convert';

import 'package:expiry_reminder/models/product_info.dart';
import 'package:http/http.dart' as http;
import 'package:expiry_reminder/shared/shared_function.dart';

class APIManager {
  Future<ProductInfo> getProductInfoFromAPI(String barcodeNumber) async {
    var client = http.Client();
    var productInfo;

    try {
      print('The barcode received by method "getProductInfoFromAPI" is -> $barcodeNumber');

      var response = await client.get(Uri.parse(Utils.barcodeUrl(barcodeNumber)));
      print(response.statusCode);
      // only carries out when there is a successful response.
      if (response.statusCode == 200) {
        var jsonString = response.body;
        var jsonDecoded = json.decode(jsonString);
        print(jsonDecoded);

        // assigning object type of ProductInfo to variable "productInfo"
        productInfo = ProductInfo.fromJson(jsonDecoded);
      } else {
        // this productInfo returned will be a null value
        return productInfo;
      }
    } catch (e) {
      print('Error has occured when using method "getProductInfoFromAPI: "$e');
    }
    // this productInfo returned will be an object of ProductInfo
    return productInfo;
  }
}
