import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../chat/services/auth/auth_gate.dart';
import '../mainScreens/earnings_screen.dart';
import '../mainScreens/history_screen.dart';
import '../mainScreens/new_orders_screen.dart';
import '../mainScreens/not_yet_delivered_screen.dart';
import '../mainScreens/parcel_in_progress_screen.dart';
import '../provider/sign_in_provider.dart';
import '../utils/currencySign.dart';
import '../utils/next_screen.dart';

class AppDrawer extends StatefulWidget {

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String currencySymbol = '';

  void currency() {
    // Example usage:
    currencySymbol = getCurrency();
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    super.initState();
    currency();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Header drawer
            Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: const DecorationImage(
                      image: AssetImage('images/background.png'), // Replace with your desired image
                      fit: BoxFit.cover,
                      opacity: 0.1
                  ),
                  gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                    Colors.yellow.shade800,
                    Colors.yellow.shade800,
                    Colors.yellow.shade600
                  ])
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    borderRadius: const BorderRadius.all(Radius.circular(80)),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage("${sp.riderAvatar}"),
                        radius: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${sp.firstName} ${sp.middleInitial} ${sp.lastName}",
                    style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Column(
                  children: [
                    ListTile(
                      title: Column(
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "EatsEasyPay",
                                        style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        "Wallet",
                                        style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.w300),
                                      )
                                    ],
                                  )
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: const BorderRadius.all(Radius.circular(7.0)),
                                        ),
                                        padding: const EdgeInsets.only(left: 5, right: 5),
                                        child: Text(
                                          '$currencySymbol 0.00',
                                          style: const TextStyle(color: Colors.black, fontSize: 15,),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Balance and payment methods",
                                style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                      onTap: () {

                      },
                    ),
                    const Divider(
                      color: Colors.grey, // Border color
                      height: 0.5,
                      indent: 17, // Indent from left
                      endIndent: 24, // Indent from right
                      thickness: 0.5, // Thickness of dashes
                    ),
                  ],
                ),

                // Home
                ListTile(
                  leading: Icon(Icons.home_outlined, color: Colors.orange.shade400),
                  title: const Text(
                    "Dashboard",
                    style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                  ),
                  onTap: () {

                  },
                ),

                // Orders
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child:
                  ListTile(
                    leading: Icon(Icons.assignment, color: Colors.orange.shade400),
                    title: const Text(
                      "New available orders",
                      style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> NewOrdersScreen()));
                    },
                  ),
                ),

                // History
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child:
                  ListTile(
                    leading: Icon(Icons.local_shipping_rounded, color: Colors.orange.shade400),
                    title: const Text(
                      "Parcels in progress",
                      style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> const ParcelInProgressScreen()));
                    },
                  ),
                ),

                // Not yet delivered
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child:
                  ListTile(
                    leading: Icon(Icons.location_history, color: Colors.orange.shade400),
                    title: const Text(
                      "Not yet delivered",
                      style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> NotYetDeliveredScreen()));
                    },
                  ),
                ),

                // History
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child:
                  ListTile(
                    leading: Icon(Icons.done_all, color: Colors.orange.shade400),
                    title: const Text(
                      "History orders",
                      style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen()));
                    },
                  ),
                ),

                //Earnings
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child:
                  ListTile(
                    leading: Icon(Icons.monetization_on_rounded, color: Colors.orange.shade400),
                    title: const Text(
                      "Earnings",
                      style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> const EarningsScreen()));

                    },
                  ),
                ),

                // Chats
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child:
                  ListTile(
                    leading: Icon(Icons.mark_chat_unread_outlined, color: Colors.orange.shade400),
                    title: const Text(
                      "Chats",
                      style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthGate()));
                    },
                  ),
                ),

                // Customer Ratings and Reviews
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child:
                  ListTile(
                    leading: Icon(Icons.star_half_rounded, color: Colors.orange.shade400),
                    title: const Text(
                      "Customer Ratings and Reviews",
                      style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                    ),
                    onTap: () {

                    },
                  ),
                ),

                // Help Center
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child:
                  ListTile(
                    leading: Icon(Icons.help_outline_rounded, color: Colors.orange.shade400),
                    title: const Text(
                      "Help Center",
                      style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                    ),
                    onTap: () {

                    },
                  ),
                ),

                // Language
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child:
                  ListTile(
                    leading: Icon(Icons.language_rounded, color: Colors.orange.shade400),
                    title: const Text(
                      "Language",
                      style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                    ),
                    onTap: () {

                    },
                  ),
                ),

                // Settings
                Column(
                  children: [
                    const Divider(
                      height: 1,
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                    ListTile(
                      title: const Text(
                        "Settings",
                        style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                      ),
                      onTap: () {

                      },
                    ),
                  ],
                ),

                // Log out
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child:
                  ListTile(
                    title: const Text(
                      "Log out",
                      style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                    ),
                    onTap: () {
                      sp.userSignOut();
                      nextScreenReplace(context, '/loginScreen');
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      )
    );
  }
}

