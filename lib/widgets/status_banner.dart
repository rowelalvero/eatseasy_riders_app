
import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {

  final bool? status;
  final String? orderStatus;

  const StatusBanner({super.key, this.status, this.orderStatus});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData iconData;

    status! ? iconData = Icons.check_circle : iconData = Icons.cancel;
    status! ? message = "Successful" : message = "Unsuccessful";
    Color iconColor = status! ? Colors.green : Colors.red;

    return Container(
      /*decoration: BoxDecoration(
        color: Colors.green
      ),*/
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 20,),
          Text(
            orderStatus == "ended"
                ? "Parcel Delivered $message"
                : "Order Placed $message",
            style: const TextStyle(
                color: Colors.black,
                fontFamily: "Poppins"
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Icon(
            iconData,
            color: iconColor,
            size: 14,
          ),
        ],
      ),

    );
  }
}
