import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'FirstScreen.dart';


class TestHttp extends StatefulWidget {
  final String url;

  TestHttp({String url}):url = url;

  @override
  State<StatefulWidget> createState() => TestHttpState();
}// TestHttp

class TestHttpState extends State<TestHttp> {
  final _formKey = GlobalKey<FormState>();

  String _url, _body, _PostLogin, _PostPassword;
  //для файрбейз
  FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;

  @override
  void initState() {
    //_url = 'https://skynetcom.koldashev.ru/test.php';
    _url = 'https://my.skynetcom.ru/api/v1/';




    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
        });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    _fcm.configure();
    }

    super.initState();
  }//initState

//запись файлов с логином и паролем
  _writeLogin(String login) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/login.txt');
    await file.writeAsString(login);
  }
  _writePass(String pass) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/pass.txt');
    await file.writeAsString(pass);
  }
  //получаем токен файрбейз
  _saveDeviceToken(String account) async {
    // Get the current user
    //String uid = 'jeffd23';
    // FirebaseUser user = await _auth.currentUser();

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      /*var tokens = _db
        .collection('users')
        .document(uid)
        .collection('tokens')
        .document(fcmToken);*/
      //print("Получили токен для номера счета $account : $fcmToken");
      var response = await http.get("https://koldashev.ru/addtoken.php?token=$fcmToken&account=$account");
      //print(response);
      /*await tokens.setData({
      'token': fcmToken,
      'createdAt': FieldValue.serverTimestamp(), // optional
      'platform': Platform.operatingSystem // optional
    });*/
    }
  }

  _sendRequestPost() async {

      if (_formKey.currentState.validate()) {
        _formKey.currentState.save(); //update form data

        try {
          var response = await http.post(_url,
              headers: {"Accept": "application/json"},
              body: jsonEncode(<String, dynamic>{"login": _PostLogin, "password": _PostPassword, "subject":1})
          );


          Map<String, dynamic> user = jsonDecode(response.body);
          _body = user['error'];

          if(_body == null){
            _writePass(_PostPassword); //пишем пароль
            _writeLogin(_PostLogin); //пишем логин
            _saveDeviceToken(user['accountnumber'].toString());// при удачной авторизации фигачим токен в бд
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => FirstScreen()));
          }

        } catch (error) {
          _body = error.toString();
        }
        setState(() {}); //reBuildWidget
      }
  }//_sendRequestPost

  _CallToHelp() async {
    const url = "tel:88001005561";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Невозможно набрать номер $url';
    }
  }

  Widget build(BuildContext context) {
    return Form(key: _formKey,
        child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                },
          child:SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Center(
                    child:Container(
                      child:Image.asset('assets/logo1.png',  height: 80, fit:BoxFit.fill,),
                      alignment: Alignment(-0.25, 0.0),
                      padding: EdgeInsets.fromLTRB(0,50,0,5),
                    )
                  ),
                  Center(
                    child:Container(
                      child: Text('ВХОД В ЛИЧНЫЙ КАБИНЕТ', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black),textAlign: TextAlign.center,),
                      padding: EdgeInsets.fromLTRB(10,30,10,10),
                      alignment: Alignment(0.0, 0.0),
                    )
                  ),
                  Container(
                      child: TextFormField(decoration: InputDecoration(hintText: "Логин", focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                      color: Colors.blue,
                      ),
                      ), enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                      ),
                      ),), /*validator: (value){if (value.isEmpty) return 'Логин не введен';},*/ onSaved: (value){_PostLogin = value;}, autovalidate: true),
                              padding: EdgeInsets.fromLTRB(40,10,40,5)
                  ),
                  Container(
                      child: TextFormField(decoration: InputDecoration(hintText: "Пароль", focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ), enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),), /*validator: (value){if (value.isEmpty) return 'Пароль не введен';},*/ onSaved: (value){_PostPassword = value;}, autovalidate: true,obscureText: true,),
                      padding: EdgeInsets.fromLTRB(40,10,40,5),
                  ),
                  SizedBox(height: 10.0),
                  RaisedButton.icon(onPressed: _sendRequestPost, icon: Icon(Icons.vpn_key), label: Text("ВХОД"),color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor: Colors.blue,
                    disabledTextColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(50,10,50,10),
                    splashColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),

                    ),

                  ),
                  SizedBox(height: 20.0),
                  //Text('Response body', style: TextStyle(fontSize: 20.0,color: Colors.blue)),
                  Text(_body == null ? '' : _body, style: TextStyle(fontSize: 15.0,color: Colors.redAccent)),
                  SizedBox(height: 20.0),
                  Center(
                      child:Container(
                        child: Text('Бесплатный звонок из любой точки РФ', style: TextStyle(fontSize: 15.0,color: Colors.grey),
                        textAlign: TextAlign.center,),
                        padding: EdgeInsets.fromLTRB(40,20,40,5),
                        alignment: Alignment(0.0, 0.0),
                      )
                  ),
                  GestureDetector(
                      onTap: () {
                        _CallToHelp();
                      },
                      child:Center(
                          child:Container(
                            child: Text('8 800 100-55-61', style: TextStyle(fontSize: 30.0,color: Colors.black),
                            textAlign: TextAlign.center,),
                            //padding: EdgeInsets.fromLTRB(5,5,5,5),
                            alignment: Alignment(0.0, 0.0),
                          )
                      ),
                  ),
                ],
    ))));
  }//build
}//TestHttpState

class LoginProcedure extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TestHttp(url: 'https://my.skynetcom.ru/api/v1/')
    );
  }

}

