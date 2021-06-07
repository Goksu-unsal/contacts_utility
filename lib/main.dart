import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromRGBO(128, 75, 246, 1)
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String value = "";
  String _message = "Formatı aşağıdaki metin alanına yapıştırabilirsin. Uygulamanın doğru çalışabilmesi için numaralar ve isimler arasında boşluk OLDUĞUNDAN, satır sonlarında boşluk OLMADIĞINDAN emin olmalısın. ";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Permission.contacts.status.then((value){
      if(value.isDenied){
        Permission.contacts.request();
      }
    });
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: Text('Programming is Magic'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(128, 75, 246, 1),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(15),
            child: Text(
                _message, style: TextStyle(color: Colors.white),),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade300,
              borderRadius: BorderRadius.circular(15)
            ),
          ),
          Flexible(
            child: TextField(
              onChanged: (_value) {
                value = _value;
              },
              maxLines: 100000,
              decoration: InputDecoration(focusColor: Colors.deepPurple ,hoverColor: Colors.deepPurple.shade300),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                saveMyData(value);
              },
              child: Text("Save")),
        ],
      ),
    );
  }

  saveMyData(String? value) {
    String fullValue = value.toString();
    print("value is:");
    print(fullValue);
    fullValue = fullValue.replaceAll("\n"," ");
    List<String> listOfSplittedValues = fullValue.split(" ");
    listOfSplittedValues.forEach((element) {
      int index = listOfSplittedValues.indexOf(element);
      if (isNumeric(element)) {
        index == 0
            ? listOfSplittedValues[index] = "$element|"
            : listOfSplittedValues[index] = "|$element|";
      } else {
        listOfSplittedValues[index] = "$element|";
      }
    });

    var concatenate = StringBuffer();

    listOfSplittedValues.forEach((item) {
      concatenate.write(item);
    });

    convertToContactList(concatenate);
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void convertToContactList(StringBuffer concatenate) {
    List<String> strContactList = concatenate.toString().split("||");
    List<MyContactModel> contactList = strContactList.map((e) {
      List<String> dataList = e.split("|");
      String _phoneNumber = dataList[0];
      dataList.removeAt(0);
      return MyContactModel(
          name: dataList.join(" "), phoneNumber: _phoneNumber);
    }).toList();
    saveContactsToPhone(contactList);
  }

  void saveContactsToPhone(List<MyContactModel> contactList) {
    print(contactList);
    for (var i = 0; i < contactList.length; i++) {
      Contact contact = Contact(
          phones: [Item(label: "mobile", value: contactList[i].phoneNumber)],
          displayName: contactList[i].name,
          givenName: contactList[i].name);
      print(contact.displayName);
      print(contact.phones);
      ContactsService.addContact(contact)
          .then((value) {
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Başarılı"),
            content: Text("Yine de herhangi bir soruna karşı kişiler listende küçük bir kontrol yapmanda fayda var. Bol başarılar bro :D "),

          );
        });
      });
    }
  }
}

class MyContactModel {
  String name;
  String phoneNumber;

  MyContactModel({this.name = "", this.phoneNumber = ""});

  @override
  String toString() {
    // TODO: implement toString
    return "$phoneNumber $name";
  }
}
