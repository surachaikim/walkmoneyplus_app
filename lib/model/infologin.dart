class infologin {
  String cusid;
  String pin;
  String username;
  String userId;
  String password;
  String name;
  String Imei;
  String cpId;
  String cpName;

  infologin(
      {required this.cusid,
      required this.pin,
      required this.username,
      required this.userId,
      required this.password,
      required this.name,
      required this.Imei,
      required this.cpId,
      required this.cpName});

  factory infologin.fromJson(Map<String, dynamic> json) {
    return infologin(
        cusid: json["cusid"],
        pin: json["pin"],
        username: json["username"],
        userId: json["userId"],
        name: json["name"],
        password: json["password"],
        Imei: json["Imei"],
        cpId: json["cpId"],
        cpName: json["cpName"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "cusid": cusid,
      "pin": pin,
      "username": username,
      "userId": userId,
      "name": name,
      "password": password,
      "cpId": cpId,
      "cpName": cpName,
      "Imei": Imei,
    };
  }

  @override
  String toString() =>
      '{cusid: $cusid, pin: $pin, username: $username,  userId: $userId,  name: $name,password: $password, cpId: $cpId,cpName: $cpName,Imei: $Imei}';
}
