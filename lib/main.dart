import 'dart:async';

//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_slide_screen/YandexMoney.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'LoginProcedure.dart';
import 'FirstScreen.dart';

//import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';


void main() {
  //_readLogin();
  runApp(MyApp());
  _readLogin();

}

String text;

class MyApp extends StatelessWidget {

  //static FirebaseAnalytics analytics = FirebaseAnalytics();
  //static FirebaseInAppMessaging fiam = FirebaseInAppMessaging();

 /* @override
  Widget build(BuildContext ctxt) {
   // _readLogin();
         return new MaterialApp(
        debugShowCheckedModeBanner: false,

        home: Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

    }*/



 @override
  Widget build(BuildContext ctxt) {
    //_readLogin();
    if (text == null){
      //print('Значение логина 1 - $text');
      return new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
      
    }
    if (text == "0"){
      //print('Значение логина 2 - $text');
      return new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginProcedure(),
      );

    }
    if ((text != '0') || (text != null)){
        //print('Значение логина 3 - $text');
      return new MaterialApp(
          debugShowCheckedModeBanner: false,
          home: FirstScreen(),
        //home: YM(),
      );
    }

  }
}

Future<String> _readLogin() async {
  //String text;
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/login.txt');
    text = await file.readAsString();
    //if(await file.readAsString() != null){runApp(MyApp());}
    //print('Успешно $text');
      //FirstScreen();
    runApp(MyApp());
  } catch (e) {
    text = "0";
    //print('Ошибка $text $e');
      //LoginProcedure();
    runApp(MyApp());
  }
  return text;
  //if(text != null){runApp(MyApp());}

}

/*class FirstScreen extends StatelessWidget {
  @override
  Widget build (BuildContext ctxt) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("1"),
          actions: <Widget>[IconButton(icon: Icon(Icons.arrow_forward_ios), tooltip: 'Code', onPressed: (){
            Navigator.push(ctxt, MaterialPageRoute(builder: (context) => SecondScreen()));
          })],
        ),
        body: Text('Экран № 1')
    );
  }
}*/

//управляем движением слайда
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightRoute({this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
  );
}




