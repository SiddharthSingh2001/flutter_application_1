import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'package:flutter_application_1/home.dart';
import 'package:sqflite/sqflite.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  TextEditingController emp_name = TextEditingController();
  TextEditingController emp_pass = TextEditingController();
  List items = [];
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    LoadView();
    // TODO: implement initState
  }

  Future<void> LoadView() async {
    var record = await DatabaseHelper.instance.queryDatabase();
    setState(() {
      items = record.map((elm) {
        String emp_id = elm['emp_id'] as String;
        String emp_name = elm['emp_name'] as String;
        String emp_pass = elm['emp_pass'] as String;
        // return '$emp_name - $emp_pass';
        return [emp_id, emp_name, emp_pass];
      }).toList();

      print('items: $items');
      //above code line is true if you have only one column named Role_Name

      // items = record;
    });
  }

  final formkey = GlobalKey<FormState>();
  bool passVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Signup Page'))),
      body: SingleChildScrollView(
        child: Form(
          key: formkey,
          child: Column(
            children: [
              SizedBox(
                  height: 200, child: Image.asset('assets/Images/login.png')),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Username';
                    }
                    return null;
                  },
                  controller: emp_name,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 3, color: Colors.deepPurple), //<-- SEE HERE
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: emp_pass,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Password';
                    }
                    return null;
                  },
                  obscureText: passVisible,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 3, color: Colors.deepPurple), //<-- SEE HERE
                      ),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              if (passVisible) {
                                passVisible = false;
                              } else {
                                passVisible = true;
                              }
                            });
                          },
                          icon: Icon(passVisible == true
                              ? Icons.visibility
                              : Icons.visibility_off))),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (formkey.currentState!.validate()) {
                      if (isEdit == true) {
                        await DatabaseHelper.instance.updateRecord({
                          DatabaseHelper.columnId: 1,
                          DatabaseHelper.columnName: emp_name.text,
                          DatabaseHelper.columnPass: emp_pass.text
                        });
                      } else {
                        await DatabaseHelper.instance.insertRecord({
                          DatabaseHelper.columnName: emp_name.text,
                          DatabaseHelper.columnPass: emp_pass.text
                        });
                      }

                      emp_name.clear();
                      emp_pass.clear();
                      FocusScope.of(context).unfocus();

                      LoadView();
                    }
                  },
                  child: Text(isEdit == false ? 'Create Account' : 'Update')),
              ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      emp_name.clear();
                      emp_pass.clear();
                      isEdit = false;

                      LoadView();
                    });
                  },
                  child: const Text('Refresh')),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  height: 400,
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(items[index][0]),
                        subtitle: Text(items[index][1]),
                        leading: IconButton(
                            onPressed: () {
                              setState(() {
                                emp_name.text = items[index][0];
                                emp_pass.text = items[index][1];
                                isEdit = true;
                              });

                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             HomePage(Uname: items[index][0])));
                            },
                            icon: Icon(Icons.edit)),
                        trailing: IconButton(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text("Are you sure?"),
                                        content: const Text(
                                            "You want to delete this"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () async {
                                              await DatabaseHelper.instance
                                                  .deleteRecord(
                                                      items[index][0]);
                                              Navigator.of(context).pop();
                                              LoadView();
                                            },
                                            child: Container(
                                              color: Color.fromARGB(
                                                  255, 175, 76, 76),
                                              padding: const EdgeInsets.all(14),
                                              child: const Text("Yes"),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              color: Colors.green,
                                              padding: const EdgeInsets.all(14),
                                              child: const Text("Cancel"),
                                            ),
                                          ),
                                        ],
                                      ));
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            )),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
