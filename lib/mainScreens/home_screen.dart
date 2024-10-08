import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatseasy_riders_app/mainScreens/earnings_screen.dart';
import 'package:eatseasy_riders_app/mainScreens/history_screen.dart';
import 'package:eatseasy_riders_app/mainScreens/not_yet_delivered_screen.dart';
import 'package:eatseasy_riders_app/mainScreens/parcel_in_progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../assistantMethods/get_current_location.dart';
import '../authentication/login.dart';
import '../global/global.dart';
import '../provider/sign_in_provider.dart';
import '../widgets/app_drawer.dart';
import 'new_orders_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
{
  Card makeDashboardItem(String title, IconData iconData, int index)
  {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Container(
        decoration: index == 0 || index == 3 || index == 4
            ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.amber,
                Colors.cyan,
              ],
              begin:  FractionalOffset(0.0, 0.0),
              end:  FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
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
        )
            : BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.yellow.shade800,
              Colors.yellow.shade800,
              Colors.yellow.shade600
            ]),
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
        child: InkWell(
          onTap: ()
          {
            if(index == 0)
            {
              //New Available Orders
              Navigator.push(context, MaterialPageRoute(builder: (c)=> NewOrdersScreen()));
            }
            if(index == 1)
            {
              //Parcels in Progress
              Navigator.push(context, MaterialPageRoute(builder: (c)=> const ParcelInProgressScreen()));
            }
            if(index == 2)
            {
              //Not Yet Delivered
              Navigator.push(context, MaterialPageRoute(builder: (c)=> NotYetDeliveredScreen()));
            }
            if(index == 3)
            {
              //History
              Navigator.push(context, MaterialPageRoute(builder: (c)=> HistoryScreen()));
            }
            if(index == 4)
            {
              //Total Earnings
              Navigator.push(context, MaterialPageRoute(builder: (c)=> const EarningsScreen()));
            }
            if(index == 5)
            {
              //Logout
              firebaseAuth.signOut().then((value){
                Navigator.push(context, MaterialPageRoute(builder: (c)=> const LogInScreen()));
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              const SizedBox(height: 50.0),
              Center(
                child: Icon(
                  iconData,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    UserLocation uLocation = UserLocation();
    uLocation.getCurrentLocation();
    getPerParcelDeliveryAmount();
    getRiderPreviousEarnings();
  }

  getRiderPreviousEarnings()
  {
    final sp = context.read<SignInProvider>();
    print("hehe");
    print(sp.uid);
    FirebaseFirestore.instance
        .collection("riders")
        .doc(sp.uid)
        .get().then((snap)
    {
      previousRiderEarnings = snap.data()!["earnings"].toString();
    });
  }

  getPerParcelDeliveryAmount()
  {
    FirebaseFirestore.instance
        .collection("perDelivery")
        .doc("rowel121102")
        .get().then((snap)
    {
      perParcelDeliveryAmount = snap.data()!["amount"].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          height: MediaQuery.of(context).size.height,
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
              ])),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0), // Adjust the left padding as needed
              child: IconButton(
                icon: const Icon(
                  Icons.menu,
                  size: 26, // Change the size of the icon as needed
                ),
                color: Colors.white,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            );
          },
        ),
        title: Text(
          "Welcome, ${sharedPreferences!.getString("firstName")!}!",
          style: const TextStyle(
            fontSize: 25.0,
            color: Colors.white,
            fontFamily: "Poppins",
            letterSpacing: 2,
            fontWeight: FontWeight.w500
          ),
        ),
        automaticallyImplyLeading: false,

      ),
      drawer: AppDrawer(),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 1),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(2),
          children: [
            makeDashboardItem("New Available Orders", Icons.assignment, 0),
            makeDashboardItem("Parcels in Progress", Icons.airport_shuttle, 1),
            makeDashboardItem("Not Yet Delivered", Icons.location_history, 2),
            makeDashboardItem("History", Icons.done_all, 3),
            makeDashboardItem("Total Earnings", Icons.monetization_on, 4),
            makeDashboardItem("Logout", Icons.logout, 5),
          ],
        ),
      ),
    );
  }
}
