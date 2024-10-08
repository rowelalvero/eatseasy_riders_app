import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../assistantMethods/assistant_methods.dart';
import '../models/vendors.dart';
import '../provider/sign_in_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/progress_bar.dart';

class ParcelInProgressScreen extends StatefulWidget {
  const ParcelInProgressScreen({super.key});

  @override
  State<ParcelInProgressScreen> createState() => _ParcelInProgressScreenState();
}

class _ParcelInProgressScreenState extends State<ParcelInProgressScreen> {
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
        title: const Text(
          'Parcels in progress',
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
            .where("status", isEqualTo: "picking")
            .snapshots(),
        builder: (c, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: circularProgress());
          }

          print("Orders snapshot data: ${snapshot.data!.docs}");

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (c, index) {
              Map<String, dynamic> orderData = snapshot.data!.docs[index].data()! as Map<String, dynamic>;
              print("Order Data: $orderData");

              List<String> productIDs = separateOrdersItemIDs(orderData["productIDs"]);
              print("Product IDs: $productIDs");

              List<String> quantitiesList = separateOrderItemQuantities(orderData["productIDs"]);
              print("Quantities List: $quantitiesList");

              // Extract the vendorsUID from the order data
              Vendors vModel = Vendors.fromJson(orderData);
              String? vendorsUID = vModel.vendorsUID;

              // Ensure vendorsUID is not null
              if (vendorsUID == null) {
                return const Center(
                  child: Text("Vendors UID is null. Please check your data."),
                );
              }

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("vendorCartData")
                    .doc(vendorsUID)
                    .collection("itemsCartData")
                    .where("itemID", whereIn: productIDs)
                    .orderBy("publishedDate", descending: true)
                    .get(),
                builder: (c, snap) {
                  if (!snap.hasData) {
                    return Center(child: circularProgress());
                  }

                  print("Items snapshot data: ${snap.data!.docs}");

                  print("Vendors: $vendorsUID");

                  return OrderCard(
                    itemCount: snap.data!.docs.length,
                    data: snap.data!.docs,
                    orderID: snapshot.data!.docs[index].id,
                    separateQuantitiesList: quantitiesList,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}