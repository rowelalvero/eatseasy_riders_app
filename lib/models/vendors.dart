class Vendors {
  String? vendorName;
  String? vendorsUID;
  String? vendorsAvatar;
  String? vendorsEmail;
  String? businessAddress;

  Vendors({
    this.vendorsUID,
    this.vendorName,
    this.vendorsAvatar,
    this.vendorsEmail,
    this.businessAddress
  });

  Vendors.fromJson(Map<String, dynamic>json) {
    vendorsUID = json["uid"];
    vendorName = json["businessName"];
    vendorsAvatar = json["vendorAvatarUrl"];
    vendorsEmail = json["email"];
    businessAddress = json["businessAddress"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["uid"] = this.vendorsUID;
    data["businessName"] = this.vendorName;
    data["vendorAvatarUrl"] = this.vendorsAvatar;
    data["email"] = this.vendorsEmail;
    data["businessAddress"] = this.businessAddress;
    return data;
  }
}