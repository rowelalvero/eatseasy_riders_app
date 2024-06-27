import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../assistantMethods/assistant_methods.dart';
import '../models/vendors.dart';
import '../provider/sign_in_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/progress_bar.dart';

class HistoryScreen extends StatefulWidget
{
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}



class _HistoryScreenState extends State<HistoryScreen>
{
  @override
  Widget build(BuildContext context) {
    final sp = context.read<SignInProvider>();
    return SafeArea(
      child: Scaffold(
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
          title: const Text(
            'History',
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
            ),
          ),
          automaticallyImplyLeading: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("riderUID", isEqualTo: sp.uid)
              .where("status", isEqualTo: "ended")
              .snapshots(),
          builder: (c, snapshot)
          {
            return snapshot.hasData
                ? ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (c, index)
              {

                Map<String, dynamic> orderData = snapshot.data!.docs[index].data()! as Map<String, dynamic>;
                print("Order Data: $orderData");

                List<String> productIDs = separateOrdersItemIDs(orderData["productIDs"]);
                print("Product IDs: $productIDs");

                List<String> quantitiesList = separateOrderItemQuantities(orderData["productIDs"]);
                print("Quantities List: $quantitiesList");

                // Extract the vendorsUID from the order data
                Vendors vModel = Vendors.fromJson(orderData);
                String? vendorsUID = vModel.vendorsUID;

                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("vendorCartData")
                      .doc(vendorsUID)
                      .collection("itemsCartData")
                      .where("itemID", whereIn: productIDs)
                      .orderBy("publishedDate", descending: true)
                      .get(),
                  builder: (c, snap)
                  {
                    return snap.hasData
                        ? OrderCard(
                      itemCount: snap.data!.docs.length,
                      data: snap.data!.docs,
                      orderID: snapshot.data!.docs[index].id,
                      separateQuantitiesList: quantitiesList,
                    )
                        : Center(child: circularProgress());
                  },
                );
              },
            )
                : Center(child: circularProgress(),);
          },
        ),
      ),
    );
  }
}
