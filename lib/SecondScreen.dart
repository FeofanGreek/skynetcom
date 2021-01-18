import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'LoginProcedure.dart';
import 'FirstScreen.dart';
import 'TreeScreen.dart';
import 'main.dart';

class TestHttp extends StatefulWidget {
  final String url;

  TestHttp({String url}):url = url;

  @override
  State<StatefulWidget> createState() => TestHttpState();
}// TestHttp

class TestHttpState extends State<TestHttp> {
  String _url;
  String blocked,accountnumber,balance,bestbefore,creditbalance,fio,tpname,periodicpay;

  String TextBlocked = 'Услуги не активны';
  var ColorBlocked = [158,62,23];
  var ColorPayment = [158,62,23];
  String LoginF,PassF;

  List<String> paytype = <String>[];
  List<String> paymethod = <String>[];
  List<String> paysubject = <String>[];
  List<String> paysumm = <String>[];
  List<String> paydate = <String>[];


  int _status;
  @override
  void initState() {
    blocked = " ";
    accountnumber = " ";
    balance = " ";
    bestbefore = " ";
    creditbalance = " ";
    fio = " ";
    tpname = " ";
    periodicpay = " ";
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
          body: {"login":LoginF,"password":PassF,"subject":"2"}

      );

      _status = response.statusCode;
      Map<String, dynamic> user = jsonDecode(response.body);

      if ((user['fio'] == 'Неверный логин') && (LoginF != "0")) {LoOutProcedure();//если введенный пароль неверен, разлогиниваемся
      }
      if ((LoginF == "0")) {FirstScreen();//если введенный пароль неверен, разлогиниваемся
      }
      blocked = user['blocked'];
      if(blocked == '0'){TextBlocked = 'Услуги активны'; ColorBlocked = [107,138,71];}
      accountnumber = user['accountnumber'];
      balance = user['balance'];
      bestbefore = user['bestbefore'];
      creditbalance = user['creditbalance'];
      fio = user['fio'];
      tpname = user['tpname'];
      periodicpay = user['periodicpay'];
      //работаем с массивом из JSON
      for(int i=0; i < user['payhistory'].length; i++){
          if (user['payhistory'][i]['paytype'] == "1") {
            paytype.add("Зачисление");
          } else {
            paytype.add("Списание");
          }
        paymethod.add(user['payhistory'][i]['paymethod']);
        paysubject.add(user['payhistory'][i]['paysubject']);
        paysumm.add(user['payhistory'][i]['paysumm']);
        paydate.add(user['payhistory'][i]['paydate']);
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
                  CupertinoPageRoute(builder: (context) => ThreeScreen()));//двигаем по умолчанию
            }
            if(dragUpdateDetails.delta.dx > 0.5) {
              Navigator.pop(context,
                  SlideRightRoute(page: FirstScreen()));// двигать надо влево
            }
          },

          child: Column(
            children: <Widget>[
              Container(
                child: Text('История платежей', style: TextStyle(fontSize: 20.0,color: Colors.blue)),
                padding: EdgeInsets.all(10.0),

              ),

              Row(
                  children: <Widget>[
                    Container(
                      child: Text('Номер лицевого счета', style: TextStyle(fontSize: 15.0,color: Colors.black)),
                      margin: EdgeInsets.fromLTRB(20,0,10,0),
                      padding: EdgeInsets.fromLTRB(0,0,0,0),
                      width: MediaQuery.of(context).size.width / 3 * 2 - 30,

                    ),
                    Center(
                        child:Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Color.fromRGBO(ColorBlocked[0], ColorBlocked[1], ColorBlocked[2], 1),
                          ),
                          child: Text('$TextBlocked', style: TextStyle(fontSize: 12.0,color: Colors.white), textAlign: TextAlign.center,),
                          padding: EdgeInsets.fromLTRB(10,10,5,10),
                          margin: EdgeInsets.fromLTRB(15,20,10,0),
                          width: MediaQuery.of(context).size.width / 3 - 25,
                          //color: Color.fromRGBO(ColorBlocked[0], ColorBlocked[1], ColorBlocked[2], 1),
                        )),

                  ]
              ),
              Row(
                  children: <Widget>[
                    Container(
                      child: Text(' $accountnumber', style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold,)),
                      padding: EdgeInsets.fromLTRB(20,0,10,0),
                      margin: EdgeInsets.fromLTRB(0,0,0,20),

                    )]),

              SizedBox(height: 5.0, width: MediaQuery.of(context).size.width - 30,
                child: const DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                ),),
              Row(
                  children: <Widget>[
                    Container(
                      child:Text('Баланс счета на ', style: TextStyle(fontSize: 15.0,color: Colors.black87), textAlign: TextAlign.left,),
                      margin: EdgeInsets.fromLTRB(50,20,0,0),
                      alignment: Alignment(-1.0, 0.0),

                    ),
                    Container(
                      child:Text(' $formattedDate', style: TextStyle(fontSize: FSize,color: Colors.black87, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                      margin: EdgeInsets.fromLTRB(0,20,0,0),
                      alignment: Alignment(-1.0, 0.0),

                    ),
                  ]),
              Container(
                child:Text(' $balance₽', style: TextStyle(fontSize: 35.0, color: Color.fromRGBO(ColorBlocked[0], ColorBlocked[1], ColorBlocked[2], 1), fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                margin: EdgeInsets.fromLTRB(50,5,0,0),
                alignment: Alignment(-1.0, 0.0),

              ),
              Row(
                  children: <Widget>[
                    Container(
                      child:Text('Услуги оплачены до ', style: TextStyle(fontSize: 15.0,color: Colors.black87), textAlign: TextAlign.left,),
                      margin: EdgeInsets.fromLTRB(50,20,0,0),
                      alignment: Alignment(-1.0, 0.0),

                    ),
                    Container(
                      child:Text(' $bestbefore', style: TextStyle(fontSize: FSize,color: Colors.black87, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                      margin: EdgeInsets.fromLTRB(0,20,0,0),
                      alignment: Alignment(-1.0, 0.0),

                    ),
                  ]),
              Container(
                child:Text('Кредитных средств на  $formattedDate - $creditbalance руб.', style: TextStyle(fontSize: 15.0,color: Colors.black87, ), textAlign: TextAlign.left,),
                margin: EdgeInsets.fromLTRB(50,10,0,20),
                alignment: Alignment(-1.0, 0.0),
                //width:MediaQuery.of(context).size.width - 180,

              ),
              //SizedBox(height: 20.0),
              Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(20,20,0,20),
                      alignment: Alignment(-1.0, 0.0),
                      child:Icon(Icons.format_list_bulleted),),
                    Container(
                        margin: EdgeInsets.fromLTRB(5,20,0,20),
                        child:Text('Платежи', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
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
                  itemCount: paytype.length,
                  itemBuilder: (BuildContext context, int index) {
                    if(paytype[index] == "Зачисление"){ColorPayment = [107,138,71];} else {ColorPayment = [158,62,23];}
                    return Container(
                      //margin: EdgeInsets.fromLTRB(50,0,0,10),
                      //alignment: Alignment(-1.0, 0.0),
                        child: Column(
                            children: <Widget>[

                              Container(
                                      margin: EdgeInsets.fromLTRB(20,20,0,0),
                                      alignment: Alignment(-1.0, 0.0),
                                      child:Text('${paytype[index]} - ${paydate[index]}:', style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(ColorPayment[0], ColorPayment[1], ColorPayment[2], 1)))),
                              Container(
                                  margin: EdgeInsets.fromLTRB(20,0,0,10),
                                  alignment: Alignment(-1.0, 0.0),
                                  child:Text('${paysubject[index]}. ${paymethod[index]}', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                              Container(
                                  margin: EdgeInsets.fromLTRB(20,5,0,0),
                                  alignment: Alignment(-1.0, 0.0),
                                  child:Text('Сумма: ${paysumm[index]}руб.', style: TextStyle(fontSize: 20.0,color: Colors.black87))),
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
              SizedBox(height: 100.0),


            ],

          ),

        ));
  }//build
}//TestHttpState

class SecondScreen extends StatelessWidget {
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
          title: Image.asset('assets/logo_mobile.png',  height: 50, fit:BoxFit.fill),
          centerTitle: true,
          backgroundColor: Color(0xFFbebebe),
          actions: <Widget>[IconButton(icon: Icon(Icons.arrow_forward_ios), color: Colors.black, tooltip: 'Дальше', onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ThreeScreen()));
          })],//пример перехода в меню
        ),
        body: TestHttp(url: 'https://skynetcom.koldashev.ru/test.php')
    );
  }
}
