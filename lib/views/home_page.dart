import 'dart:convert';
import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:userlist/model/user.dart';

class HomePage extends StatefulWidget {
  User? user;
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  late SharedPreferences prefs;
  List users = [];
  final formKey = GlobalKey<FormState>();
  setupUser() async {
    prefs = await SharedPreferences.getInstance();
    String? stringUser = prefs.getString('user');
    List userList = jsonDecode(stringUser!);
    for (var user in userList) {
      setState(() {
        users.add(User().fromJson(user));
      });
    }
  }

  void saveUser() {
    List items = users.map((e) => e.toJson()).toList();
    prefs.setString('user', jsonEncode(items));
  }

  @override
  void initState() {
    super.initState();
    setupUser();
  }

  Color appcolor = const Color.fromRGBO(58, 66, 86, 1.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appcolor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Users"),
        backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: formKey,
              child: Column(
                children: [
                  Container(
                      child: colorOverride(TextFormField(
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Enter valid email'
                            : null,
                    onChanged: (data) {
                      user!.title = data;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.white),
                      labelText: "Email",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    controller: emailController,
                  ))),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                      child: colorOverride(TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.length != 10) {
                        return 'Enter correct phone number';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (data) {
                      user!.number = data;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.white),
                      labelText: "Phone number",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    controller: numberController,
                  ))),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    child: const Text(
                      'Add User',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      final isValidForm = formKey.currentState!.validate();
                      if (isValidForm) {
                        addUser();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      elevation: 8.0,
                      margin:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(64, 75, 96, .9),
                        ),
                        child: makeListTile(users[index], index),
                      ));
                }),
          ),
        ],
      ),
    );
  }

  addUser() async {
    int id = Random().nextInt(30);
    User t = User(
        id: id,
        title: emailController.text,
        number: numberController.text,
        status: false);
    if (t.title!.isEmpty || t.number!.isEmpty) {
      showDialog(
          context: context,
          builder: (ctx1) {
            return AlertDialog(
              title: const Text('Please provide full details'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx1).pop();
                    },
                    child: const Text('Close'))
              ],
            );
          });
    } else if (t != null) {
      setState(() {
        users.add(t);
      });
      saveUser();
    }
  }

  makeListTile(User user, index) {
    return ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: const EdgeInsets.only(right: 12.0),
          decoration: const BoxDecoration(
              border:
                  Border(right: BorderSide(width: 1.0, color: Colors.white24))),
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            child: Text("${index + 1}"),
          ),
        ),
        title: Row(
          children: [
            Text(
              user.title!,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 10,
            ),
            user.status!
                ? const Icon(
                    Icons.verified,
                    color: Colors.greenAccent,
                  )
                : Container()
          ],
        ),
        subtitle: Wrap(
          children: <Widget>[
            Text(user.number!,
                overflow: TextOverflow.clip,
                maxLines: 1,
                style: const TextStyle(color: Colors.white))
          ],
        ),
        trailing: InkWell(
            onTap: () {
              delete(user);
            },
            child: const Icon(Icons.delete, color: Colors.white, size: 30.0)));
  }

  delete(User user) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Alert"),
              content: const Text("Are you sure to delete"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text("No")),
                TextButton(
                    onPressed: () {
                      setState(() {
                        users.remove(user);
                      });
                      Navigator.pop(ctx);
                      saveUser();
                    },
                    child: const Text("Yes"))
              ],
            ));
  }

  Widget colorOverride(Widget child) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.white,
        hintColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
      ),
      child: child,
    );
  }
}
