import 'package:murafiq/core/functions/errorHandler.dart';

class GetPrice {
  static getPrice({required distance}) async {
    
    final response = await sendRequestWithHandler(
        method: "post",
        endpoint: "/public/get-price",
        body: {"distance": distance});
    print(response.toString());
    if (response != null && response["status"] == "success") {
      return response["data"];
    } else {
      return 0;
    }
  }
}
