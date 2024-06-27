import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../assistantMethods/get_current_location.dart';
import '../global/global.dart';
import '../maps/map_utils.dart';
import '../provider/sign_in_provider.dart';
import '../splashScreen/splash_screen.dart';


class ParcelDeliveringScreen extends StatefulWidget
{
  String? purchaserId;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;
  String? vendorId;
  String? getOrderId;

  ParcelDeliveringScreen({super.key,
    this.purchaserId,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
    this.vendorId,
    this.getOrderId,
  });


  @override
  _ParcelDeliveringScreenState createState() => _ParcelDeliveringScreenState();
}

class _ParcelDeliveringScreenState extends State<ParcelDeliveringScreen>
{

  String orderTotalAmount = '';

  confirmParcelHasBeenDelivered(getOrderId, vendorId, purchaserId, purchaserAddress, purchaserLat, purchaserLng)
  {
    print("sssssssssssssssssssss"+previousRiderEarnings);
    double prevRiderEarnings = double.parse(previousRiderEarnings);
    double perParcelDeliveryFee= double.parse(perParcelDeliveryAmount);
    String riderNewTotalEarningAmount = (prevRiderEarnings + perParcelDeliveryFee).toString();

    final sp = context.read<SignInProvider>();
    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderId).update({
      "status": "ended",
      "address": completeAddress,
      "lat": position!.latitude,
      "lng": position!.longitude,
      "earnings": perParcelDeliveryAmount, //pay per parcel delivery amount
    }).then((value)
    {
      FirebaseFirestore.instance
          .collection("riders")
          .doc(sp.uid)
          .update(
          {
            "earnings": riderNewTotalEarningAmount, //total earnings amount of rider
          });
    }).then((value)
    {
      FirebaseFirestore.instance
          .collection("vendors")
          .doc(widget.vendorId)
          .update(
          {
            "earnings": (double.parse(orderTotalAmount) + (double.parse(previousEarnings))).toString(), //total earnings amount of seller

          });
    }).then((value)
    {
      FirebaseFirestore.instance
          .collection("users")
          .doc(purchaserId)
          .collection("orders")
          .doc(getOrderId).update(
          {
            "status": "ended",
            "riderUID": sp.uid,
          });
    });

    Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
  }

  getOrderTotalAmount()
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.getOrderId)
        .get()
        .then((snap)
    {
      orderTotalAmount = snap.data()!["totalAmount"].toString();
      widget.vendorId = snap.data()!["vendorUID"].toString();
    }).then((value)
    {
      getVendorData();
    });
  }

  getVendorData()
  {
    FirebaseFirestore.instance
        .collection("vendors")
        .doc(widget.vendorId)
        .get().then((snap)
    {
      previousEarnings = snap.data()!["earnings"].toString();
    });
  }

  @override
  void initState() {
    super.initState();

    //rider location update
    UserLocation uLocation = UserLocation();
    uLocation.getCurrentLocation();

    getOrderTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset(
            "images/confirm2.png",
            //width: 350,
          ),

          const SizedBox(height: 5,),

          GestureDetector(
            onTap: ()
            {
              //show location from rider current location towards vendor location
              MapUtils.launchMapFromSourceToDestination(position!.latitude, position!.longitude, widget.purchaserLat, widget.purchaserLng);
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
                      "Show delivery drop-off location",
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
                  //rider location update
                  UserLocation uLocation = UserLocation();
                  uLocation.getCurrentLocation();

                  //confirmed - that rider has picked parcel from vendor
                  confirmParcelHasBeenDelivered(
                      widget.getOrderId,
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
                      "Order has been Delivered - Confirm",
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
