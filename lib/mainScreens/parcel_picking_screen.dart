import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatseasy_riders_app/mainScreens/parcel_delivering_screen.dart';
import 'package:flutter/material.dart';

import '../assistantMethods/get_current_location.dart';
import '../global/global.dart';
import '../maps/map_utils.dart';

class ParcelPickingScreen extends StatefulWidget
{
  String? purchaserId;
  String? vendorId;
  String? getOrderID;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;

  ParcelPickingScreen({
    super.key,
    this.purchaserId,
    this.vendorId,
    this.getOrderID,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
  });

  @override
  _ParcelPickingScreenState createState() => _ParcelPickingScreenState();
}



class _ParcelPickingScreenState extends State<ParcelPickingScreen>
{
  double? vendorLat, vendorLng;

  getVendorData() async
  {
    FirebaseFirestore.instance
        .collection("vendors")
        .doc(widget.vendorId)
        .get()
        .then((DocumentSnapshot)
    {
      vendorLat = DocumentSnapshot.data()!["lat"];
      vendorLng = DocumentSnapshot.data()!["lng"];
    });
  }

  @override
  void initState() {
    super.initState();

    getVendorData();
  }

  confirmParcelHasBeenPicked(getOrderId, vendorId, purchaserId, purchaserAddress, purchaserLat, purchaserLng)
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderId).update({
      "status": "delivering",
      "address": completeAddress,
      "lat": position!.latitude,
      "lng": position!.longitude,
    });

    Navigator.push(context, MaterialPageRoute(builder: (c)=> ParcelDeliveringScreen(
      purchaserId: purchaserId,
      purchaserAddress: purchaserAddress,
      purchaserLat: purchaserLat,
      purchaserLng: purchaserLng,
      vendorId: vendorId,
      getOrderId: getOrderId,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset(
            "images/confirm1.png",
            width: 350,
          ),

          const SizedBox(height: 5,),

          GestureDetector(
            onTap: ()
            {
              //show location from rider current location towards vendor location
              MapUtils.launchMapFromSourceToDestination(position!.latitude, position!.longitude, vendorLat, vendorLng);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset(
                  'images/restaurant.png',
                  width: 50,
                ),

                const SizedBox(width: 7,),

                const Column(
                  children: [
                    SizedBox(height: 12,),

                    Text(
                      "Show Cafe/Restaurant Location",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),

          const SizedBox(height: 40,),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: InkWell(
                onTap: ()
                {
                  UserLocation uLocation = UserLocation();
                  uLocation.getCurrentLocation();

                  //confirmed - that rider has picked parcel from vendor
                  confirmParcelHasBeenPicked(
                      widget.getOrderID,
                      widget.vendorId,
                      widget.purchaserId,
                      widget.purchaserAddress,
                      widget.purchaserLat,
                      widget.purchaserLng
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan,
                          Colors.amber,
                        ],
                        begin:  FractionalOffset(0.0, 0.0),
                        end:  FractionalOffset(1.0, 0.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp,
                      )
                  ),
                  width: MediaQuery.of(context).size.width - 90,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Order has been Picked - Confirmed",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

}
