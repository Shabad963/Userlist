class User {
  int? id;
  String? title;
  String? number;
  bool? status;

  User({this.id, this.title, this.number, this.status}) {
    id = id;
    title = title;
    number = number;
    status = status;
  }

  toJson() {
    return {"id": id, "description": number, "title": title, "status": status};
  }

  fromJson(jsonData) {
    return User(
        id: jsonData['id'],
        title: jsonData['title'],
        number: jsonData['description'],
        status: jsonData['status']);
  }
}
