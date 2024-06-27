import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../mainScreens/orders_details_screen.dart';
import '../models/items.dart';
import '../utils/currencySign.dart';

class OrderCard extends StatelessWidget {
  final int? itemCount;
  final List<DocumentSnapshot>? data;
  final String? orderID;
  final List<String>? separateQuantitiesList;

  const OrderCard({super.key,
    this.itemCount,
    this.data,
    this.orderID,
    this.separateQuantitiesList,
  });

  @override
  Widget build(BuildContext context) {
    print('OrderCard build called');
    print('itemCount: $itemCount');
    print('data: $data');
    print('orderID: $orderID');
    print('separateQuantitiesList: $separateQuantitiesList');

    if (itemCount == null || data == null || separateQuantitiesList == null) {
      return const Center(child: Text('No data available'));
    }

    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => OrdersDetailsScreen(orderID: orderID)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black12, // Specify the border color here
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 9,
              offset: const Offset(0, 5), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        height: itemCount! * 115,
        child: ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) {
            print('Building item $index');
            Items model = Items.fromJson(data![index].data() as Map<String, dynamic>);
            return placedOrderDesignWidget(model, context, separateQuantitiesList![index]);
          },
        ),
      ),
    );
  }
}

Widget placedOrderDesignWidget(Items model, BuildContext context, String separateQuantitiesList) {
  return Padding(
  padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 10.0, bottom: 10.0),
  child: Row(
    children: [
      Expanded(
        flex: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11.0), // Adjust the value as per your requirement
              child: Image.network(
                model.thumbnailUrl!,
                height: 80.0,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
      Expanded(
        flex: 6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.itemTitle!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    )
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.only(right: 1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "x $separateQuantitiesList",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w300
                            ),
                          ),
                        ],
                      ),
                    )
                ),
                Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              getCurrency(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              model.itemPrice.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                )
              ],
            )
          ],
        ),
      )
    ],
  ),
  );
}
