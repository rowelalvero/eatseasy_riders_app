import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatseasy_riders_app/assistantMethods/get_current_location.dart';
import 'package:eatseasy_riders_app/mainScreens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../global/global.dart';
import '../mainScreens/parcel_picking_screen.dart';
import '../models/address.dart';
import '../provider/sign_in_provider.dart';

class ShipmentAddressDesign extends StatelessWidget {

  final Address? model;
  final String? orderStatus;
  final String? orderId;
  final String? vendorId;
  final String? orderByUser;

  const ShipmentAddressDesign({super.key, this.model, this.orderStatus, this.orderId, this.vendorId, this.orderByUser});

  confirmedParcelShipment(BuildContext context, String getOrderID, String vendorId, String purchaserId)
  {
    final sp = context.read<SignInProvider>();
    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderID)
        .update({
      "riderUID": sp.uid,
      "status": "picking",
      "lat": position?.latitude,
      "lng": position?.longitude,
      "address": completeAddress,
    });

    //send rider to shipmentScreen
    Navigator.push(context, MaterialPageRoute(builder: (context) => ParcelPickingScreen(
      purchaserId: purchaserId,
      purchaserAddress: model!.fullAddress,
      purchaserLat: model!.lat,
      purchaserLng: model!.lng,
      vendorId: vendorId,
      getOrderID: getOrderID,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(18.0),
          child: Text(
            "Shipping Details",
            style: TextStyle(
                fontFamily: "Poppins",
                color: Colors.black,
                fontWeight: FontWeight.w600
            ),
          ),
        ),
        const SizedBox(
          height: 6.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 5),
          width: MediaQuery.of(context).size.width,
          child: Table(
            children: [
              TableRow(
                children: [
                  const Text("Name:",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600
                      )
                  ),
                  Text(model!.name.toString(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins",
                      )
                  ),
                ],
              ),
              TableRow(
                  children: [
                    const Text("Phone Number:",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600
                        )
                    ),
                    Text(model!.phoneNumber.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins",
                        )
                    ),
                  ]
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(model!.fullAddress!,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontFamily: "Poppins"
            ),
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),

        orderStatus == 'ended'
            ? Container()
            : Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    UserLocation uLocation = UserLocation();
                    uLocation.getCurrentLocation();

                    confirmedParcelShipment(context, orderId!, vendorId!, orderByUser!);

                  },
                  // Register button styling
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 242, 198, 65),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4, // Elevation for the shadow
                    shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                  ),
                  child: const Text(
                    "Confirm - To deliver this parcel",
                    style: TextStyle(
                      color: Color.fromARGB(255, 67, 83, 89),
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen())),
                  // Register button styling
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 242, 198, 65),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4, // Elevation for the shadow
                    shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                  ),
                  child: const Text(
                    "Go back",
                    style: TextStyle(
                      color: Color.fromARGB(255, 67, 83, 89),
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
