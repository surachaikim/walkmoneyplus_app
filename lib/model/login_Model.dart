class Users {
  String username;
  String password;

  Users({
    required this.username,
    required this.password,
  });

  factory Users.fromJson(Map<String, dynamic> json) =>
      Users(username: json["username"], password: json["password"]);
}
