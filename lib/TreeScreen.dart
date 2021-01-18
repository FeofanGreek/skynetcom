import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'FirstScreen.dart';
import 'LoginProcedure.dart';
import 'SecondScreen.dart';
//import 'main.dart';
import 'QRgenerate.dart';

class TestHttp extends StatefulWidget {
  final String url;

  TestHttp({String url}):url = url;

  @override
  State<StatefulWidget> createState() => TestHttpState();
}// TestHttp

class TestHttpState extends State<TestHttp> {
  String _url;
  String accountnumber,fio,tpname;

  var ColorPayment = [158,62,23];
  String LoginF,PassF;

  List<String> mestype = <String>[];
  List<String> mestopic = <String>[];
  List<String> mesbody = <String>[];
  List<String> mesdate = <String>[];



  int _status;
  @override
  void initState() {
    accountnumber = " ";
    tpname = " ";
    _url = widget.url;

    sendFirstRequestPost();
    super.initState();
  }//initState

  //процедура выхода из аккаунта
  LoOutProcedure() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File fileL = File('${directory.path}/login.txt');
    await fileL.writeAsString('0');
    final File fileP = File('${directory.path}/pass.txt');
    await fileP.writeAsString('0');

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LoginProcedure()));
  }

  //посылаем первый запрос при загрузке данного экрана
  sendFirstRequestPost() async {
    try {
      //String LoginF;
      //String PassF;
      final Directory directory = await getApplicationDocumentsDirectory();
      final File fileL = File('${directory.path}/login.txt');
      LoginF = await fileL.readAsString();
      final File fileP = File('${directory.path}/pass.txt');
      PassF = await fileP.readAsString();
      var response = await http.post(_url,
          headers: {"Accept":"application/json"},
          body: {"login":LoginF,"password":PassF,"subject":"3"}

      );

      _status = response.statusCode;
      Map<String, dynamic> user = jsonDecode(response.body);

      if ((user['fio'] == 'Неверный логин') && (LoginF != "0")) {LoOutProcedure();//если введенный пароль неверен, разлогиниваемся
      }
      if ((LoginF == "0")) {FirstScreen();//если введенный пароль неверен, разлогиниваемся
      }
      accountnumber = user['accountnumber'];
      fio = user['fio'];
      tpname = user['tpname'];
      //работаем с массивом из JSON
      for(int i=0; i < user['messagehistory'].length; i++){
        if (user['messagehistory'][i]['mestype'] == "1") {
          mestype.add("Ваш вопрос");
        } else {
          mestype.add("Ответ");
        }
        mestopic.add(user['messagehistory'][i]['mestopic']);
        mesbody.add(user['messagehistory'][i]['mesbody']);
        mesdate.add(user['messagehistory'][i]['mesdate']);

      }
    } catch (error) { FirstScreen();}
    setState(() {});//reBuildWidget
  }


  _CallToHelp() async {
    const url = "tel:88001005561";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Невозможно набрать номер $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd.MM.yyyy').format(now);
    double FSize;
    if(MediaQuery.of(context).size.width > 350) {FSize = 17.0;} else {FSize = 15.0;}//подстраиваем размер шрифта от ширины экрана
    return SingleChildScrollView(
        physics: ScrollPhysics(),
        child: GestureDetector(// двигалка экрана
          onHorizontalDragUpdate: (dragUpdateDetails) {
            if(dragUpdateDetails.delta.dx < -0.5) {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => QRgenerator()));//двигаем по умолчанию
            }
            if(dragUpdateDetails.delta.dx > 0.5) {
              Navigator.pop(context,
                  CupertinoPageRoute(builder: (context) => SecondScreen()));// двигать надо влево
            }
          },
          onTap: () {

            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
            children: <Widget>[
              Container(
                child: Text('История сообщений', style: TextStyle(fontSize: 20.0,color: Colors.blue)),
                padding: EdgeInsets.all(10.0),

              ),
              Container(
                      child: Text('Номер лицевого счета', style: TextStyle(fontSize: 15.0,color: Colors.black)),
                      margin: EdgeInsets.fromLTRB(20,0,10,0),
                      padding: EdgeInsets.fromLTRB(0,0,0,0),
                      width: MediaQuery.of(context).size.width - 30,
                      alignment: Alignment(-1.0, 0.0),
                    ),
               Container(
                      child: Text(' $accountnumber', style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold,)),
                      padding: EdgeInsets.fromLTRB(20,0,10,0),
                      margin: EdgeInsets.fromLTRB(0,0,0,20),
                      alignment: Alignment(-1.0, 0.0),
                    ),
              SizedBox(height: 20.0),
              Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(20,20,0,20),
                      alignment: Alignment(-1.0, 0.0),
                      child:Icon(Icons.send),),
                    Container(
                        margin: EdgeInsets.fromLTRB(5,20,0,20),
                        child:Text('Новое сообщение', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                  ]),
              SizedBox(height: 5.0, width: MediaQuery.of(context).size.width - 30,
                child: const DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                ),),
              Container(
                  child: TextFormField(decoration: InputDecoration(hintText: "Тема сообщения", focusedBorder: OutlineInputBorder(
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
                  ),), /*validator: (value){if (value.isEmpty) return 'Логин не введен';}, onSaved: (value){_PostLogin = value;},*/ autovalidate: true),
                  padding: EdgeInsets.fromLTRB(40,10,40,5)
              ),
              Container(
                child: TextField(maxLines: 8, decoration: InputDecoration(hintText: "Текст сообщения", focusedBorder: OutlineInputBorder(
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
                ),), /*validator: (value){if (value.isEmpty) return 'Пароль не введен';}, onSaved: (value){_PostPassword = value;}, autovalidate: true,*/),
                padding: EdgeInsets.fromLTRB(40,10,40,5),
              ),
              SizedBox(height: 10.0),
              RaisedButton.icon(onPressed: (){FocusScope.of(context).requestFocus(new FocusNode()); /*_sendRequestPost,*/}, icon: Icon(Icons.send), label: Text("Отправить"),color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.blue,
                disabledTextColor: Colors.white,
                padding: EdgeInsets.fromLTRB(50,10,50,10),
                splashColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),

                ),),
              SizedBox(height: 20.0),

              Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(20,20,0,20),
                      alignment: Alignment(-1.0, 0.0),
                      child:Icon(Icons.message),),
                    Container(
                        margin: EdgeInsets.fromLTRB(5,20,0,20),
                        child:Text('Сообщения', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                  ]),
              SizedBox(height: 5.0, width: MediaQuery.of(context).size.width - 30,
                child: const DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                ),),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: mestype.length,
                  itemBuilder: (BuildContext context, int index) {
                    if(mestype[index] == "Ваш вопрос"){ColorPayment = [107,138,71];} else {ColorPayment = [158,62,23];}
                    return Container(
                      //margin: EdgeInsets.fromLTRB(50,0,0,10),
                      //alignment: Alignment(-1.0, 0.0),
                        child: Column(
                            children: <Widget>[

                              Container(
                                  margin: EdgeInsets.fromLTRB(20,20,0,0),
                                  alignment: Alignment(-1.0, 0.0),
                                  child:Text('${mesdate[index]}: ${mestype[index]}', style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(ColorPayment[0], ColorPayment[1], ColorPayment[2], 1)))),
                              SizedBox(height: 5.0),
                              Container(
                                  margin: EdgeInsets.fromLTRB(20,0,0,10),
                                  alignment: Alignment(-1.0, 0.0),
                                  child:Text('${mestopic[index]}: ${mesbody[index]}', style: TextStyle(fontSize: 18.0,color: Colors.black87))),
                              SizedBox(height: 1.0, width: MediaQuery.of(context).size.width - 50,
                                child: const DecoratedBox(
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                  ),
                                ),),
                              SizedBox(height: 20.0),

                            ]
                        )
                    );
                  }

              ),

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
              SizedBox(height: 100.0),


            ],

          ),

        ));
  }//build
}
class ThreeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          //title: Text('Услуги'),
          title: Image.asset('assets/logo1.png',  height: 50, fit:BoxFit.fill),
          centerTitle: true,
          backgroundColor: Color(0xFFffffff),
          actions: <Widget>[IconButton(icon: Icon(Icons.arrow_forward_ios), color: Colors.black, tooltip: 'Дальше', onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => QRgenerator()));
          })],//пример перехода в меню
        ),
        body: TestHttp(url: 'https://skynetcom.koldashev.ru/test.php')
    );

  }

}