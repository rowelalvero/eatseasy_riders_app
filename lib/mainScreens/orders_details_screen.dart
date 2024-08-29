import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/address.dart';
import '../provider/sign_in_provider.dart';
import '../utils/currencySign.dart';
import '../widgets/progress_bar.dart';
import '../widgets/shipment_address_design.dart';
import '../widgets/status_banner.dart';

class OrdersDetailsScreen extends StatefulWidget {
  final String? orderID;

  const OrdersDetailsScreen({super.key, this.orderID});

  @override
  State<OrdersDetailsScreen> createState() => _OrdersDetailsScreenState();
}

class _OrdersDetailsScreenState extends State<OrdersDetailsScreen> {
  String orderStatus = "";
  String orderByUser = "";
  String vendorId = "";

  getOrderInfo()
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID).get().then((DocumentSnapshot)
    {
      orderStatus = DocumentSnapshot.data()!["status"].toString();
      orderByUser = DocumentSnapshot.data()!["orderBy"].toString();
      vendorId = DocumentSnapshot.data()!["uid"].toString();
    });
  }

  @override
  void initState() {
    super.initState();

    getOrderInfo();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.read<SignInProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
                color: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
        title: const Text('',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w500,
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("orders")
              .doc(widget.orderID!)
              .get(),
          builder: (c, snapshot) {
            Map? dataMap;
            if(snapshot.hasData) {
              dataMap = snapshot.data!.data()! as Map<String, dynamic>;
              orderStatus = dataMap["status"].toString();
            }
            return snapshot.hasData
                ? Container(
              child: Column(
                children: [
                  StatusBanner(
                    status: dataMap!["isSuccess"],
                    orderStatus: orderStatus,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        getCurrency() + dataMap["totalAmount"].toString(),
                        style: const TextStyle(
                            fontSize: 24,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Order Id: ${widget.orderID!}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                  Text(
                    "Order at: ${DateFormat("dd MMMM, yyyy - hh:mm aa")
                        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(dataMap["orderTime"])))}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontFamily: "Poppins",
                        color: Colors.grey
                    ),
                  ),
                  const Divider(thickness: 2),
                  orderStatus == "ended"
                      ? Image.asset("images/delivered.jpg")
                      : Image.asset("images/state.jpg"),
                  const Divider(thickness: 2),
                  FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          .doc(orderByUser)
                          .collection("userAddress").doc(dataMap["addressID"])
                          .get(),
                      builder: (c, snapshot) {
                        return snapshot.hasData
                            ? ShipmentAddressDesign(
                          model: Address.fromJson(
                              snapshot.data!.data()! as Map<String, dynamic>
                          ),
                          orderStatus: orderStatus,
                          orderId: widget.orderID,
                          vendorId: vendorId,
                          orderByUser: orderByUser,
                        )
                            : Center(child: circularProgress()
                        );
                      })
                ],
              ),
            )
                : Center(child: circularProgress());
          },
        ),
      ),
    );
  }
}