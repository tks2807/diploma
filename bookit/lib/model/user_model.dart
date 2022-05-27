class UserModel {
  String name = '', email = '';
  bool isStaff = false;

  UserModel({required this.name, required this.email});

  UserModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    isStaff = json['isStaff'] == null ? false : json['isStaff'] as bool;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['name'] = this.name;
    data['isStaff'] = this.isStaff;
    return data;
  }
}