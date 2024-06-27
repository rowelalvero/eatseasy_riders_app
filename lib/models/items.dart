import 'package:cloud_firestore/cloud_firestore.dart';

class Items {
  String? menuID;
  String? itemID;
  String? vendorUID;
  String? itemTitle;
  String? itemDescription;
  double? itemPrice;
  Timestamp? publishedDate;
  String? thumbnailUrl;
  String? status;

  Items({
    this.menuID,
    this.itemID,
    this.vendorUID,

    this.itemTitle,
    this.itemDescription,
    this.itemPrice,
    this.publishedDate,
    this.thumbnailUrl,
    this.status,
  });

  Items.fromJson(Map<String, dynamic> json) {
    menuID = json["menuID"];
    itemID = json["itemID"];
    vendorUID = json["vendorUID"];
    itemTitle = json["itemTitle"];
    itemDescription = json["itemDescription"];
    itemPrice = json["itemPrice"];
    publishedDate = json["publishedDate"];
    thumbnailUrl = json["thumbnailUrl"];
    status = json["status"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["menuID"] = menuID;
    data["itemID"] = itemID;
    data["vendorUID"] = vendorUID;
    data["itemTitle"] = itemTitle;
    data["itemDescription"] = itemDescription;
    data["itemPrice"] = itemPrice;
    data["publishedDate"] = publishedDate;
    data["thumbnailUrl"] = thumbnailUrl;
    data["status"] = status;

    return data;
  }
}