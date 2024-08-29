import 'package:cloud_firestore/cloud_firestore.dart';

class Menus {
  String? menuID;
  String? vendorUID;
  String? menuTitle;
  String? menuDescription;
  //String? menuPrice;
  Timestamp? publishedDate;
  String? thumbnailUrl;
  String? status;

  Menus({
    this.menuID,
    this.vendorUID,
    this.menuTitle,
    this.menuDescription,
    //this.menuPrice,
    this.publishedDate,
    this.thumbnailUrl,
    this.status,
  });

  Menus.fromJson(Map<String, dynamic> json) {
    menuID = json["menuID"];
    vendorUID = json["uid"];
    menuTitle = json["menuTitle"];
    menuDescription = json["menuDescription"];
    //menuPrice = json["menuPrice"];
    publishedDate = json["publishedDate"];
    thumbnailUrl = json["thumbnailUrl"];
    status = json["status"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["menuID"] = menuID;
    data["uid"] = vendorUID;
    data["menuTitle"] = menuTitle;
    data["menuDescription"] = menuDescription;
    //data["menuPrice"] = menuPrice;
    data["publishedDate"] = publishedDate;
    data["thumbnailUrl"] = thumbnailUrl;
    data["status"] = status;

    return data;
  }
}