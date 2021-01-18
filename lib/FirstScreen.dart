
//import 'dart:async';
import 'dart:io';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';


import 'LoginProcedure.dart';
import 'QRgenerate.dart';
//import 'SecondScreen.dart';
//import 'main.dart';

//String bestbefore,fio,phone,email,tpname,smotreshka;

DateTime today = new DateTime.now();

class TestHttp extends StatefulWidget {
  final String url;

  TestHttp({String url}):url = url;

  @override
  State<StatefulWidget> createState() => TestHttpState();
}// TestHttp

class TestHttpState extends State<TestHttp> {

  String _url;
  String bestbefore,fio,phone,email,tpname,smotreshka;


  int accountnumber;

  double creditbalance,balance,periodicpay,topay;
  var blocked;
  var borndate;

  String TextBlocked = 'Услуги не активны';
  var ColorBlocked = [158,62,23];
  String LoginF, PassF, TVsatus;

  List<String> servicename = <String>[];
  List<String> tarifname = <String>[];
  List<double> servicecost = <double>[];

  int _status;
  @override
  void initState() {
    blocked = 0;
    accountnumber = 0;
    balance = 0.0;
    bestbefore = " ";
    creditbalance = 0.0;
    fio = " ";
    phone = " ";
    email = " ";
    //borndate = 0;
    tpname = " ";
    periodicpay = 0.0;
    topay = 0.0;
    smotreshka = " ";
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
        final Directory directory = await getApplicationDocumentsDirectory();
        final File fileL = File('${directory.path}/login.txt');
        LoginF = await fileL.readAsString();
        final File fileP = File('${directory.path}/pass.txt');
        PassF = await fileP.readAsString();
        var response = await http.post(_url,
            headers: {"Accept":"application/json"},
            body: jsonEncode(<String, dynamic>{"login":LoginF,"password":PassF,"subject":1}));

        _status = response.statusCode;
        Map<String, dynamic> user = jsonDecode(response.body);

        if ((user['error'] != null) && (LoginF != "0")) {LoOutProcedure();}//если введенный пароль неверен, разлогиниваемся

        if ((LoginF == "0")) {FirstScreen();}//если введенный пароль неверен, разлогиниваемся

        blocked = user['blocked'];
        //var blocked = new DateTime.fromMillisecondsSinceEpoch(user['blocked']*1000);
        //print(blocked);
        //if(blocked.isAfter(DateTime.now())){TextBlocked = 'Услуги активны'; ColorBlocked = [107,138,71];}
        if(blocked == 4294967295){TextBlocked = 'Услуги активны'; ColorBlocked = [107,138,71];}
        accountnumber = user['accountnumber'];
        balance = user['balance'];
        bestbefore = user['bestbefore'];
        //print(bestbefore);
        creditbalance = user['creditbalance'].toDouble();
        fio = user['fio'];
        phone = user['phone'];
        email = user['email'];
        borndate = DateFormat('dd.MM.yyyy').format(new DateTime.fromMillisecondsSinceEpoch(user['createdate']*1000));
        tpname = user['tpname'];
        periodicpay = user['periodicpay'].toDouble();
        topay = user['topay'].toDouble();
        //smotreshka = user['smotreshka'];
        //if(smotreshka == "0") {TVsatus = "ЦИФРОВОЕ ТВ НЕ ПОДКЛЮЧЕНО";}
        //работаем с массивом из JSON
        for(int i=0; i < user['services'].length; i++){
          //print(user['turnonservices'][i]);
          servicename.add(user['services'][i]['service_name']);
          tarifname.add(user['services'][i]['tariff_name']);
          servicecost.add(user['services'][i]['cost'].toDouble());
          //print(servicename[i]);
          //print(servicecost[i]);

        }

      } catch (error) {FirstScreen();}
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
  _persData() async {
    const url = "https://skynetcom.ru/files/doc.pdf";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Невозможно перейти по ссылке $url';
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
                    CupertinoPageRoute(builder: (context) => QRgenerator()));

              }
            },
            onTap: () {

              FocusScope.of(context).requestFocus(new FocusNode());
            },
              child: Column(
               children: <Widget>[
                  Container(
                      child: Text('Профиль абонента', style: TextStyle(fontSize: 20.0,color: Colors.blue)),
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
                                    child:Text('К оплате до ', style: TextStyle(fontSize: 15.0,color: Colors.black87), textAlign: TextAlign.left,),
                                    margin: EdgeInsets.fromLTRB(50,20,0,0),
                                    alignment: Alignment(-1.0, 0.0),

                                  ),
                                  Container(
                                    child:Text('$bestbefore', style: TextStyle(fontSize: FSize,color: Colors.black87, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                                    margin: EdgeInsets.fromLTRB(0,20,0,0),
                                    alignment: Alignment(-1.0, 0.0),

                                  ),

                                ]),
                           Container(
                             child:Text(' $topay₽', style: TextStyle(fontSize: 35.0,color: Color.fromRGBO(ColorBlocked[0], ColorBlocked[1], ColorBlocked[2], 1), fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                             margin: EdgeInsets.fromLTRB(50,0,0,30),
                             alignment: Alignment(-1.0, 0.0),

                           ),
                            RaisedButton.icon(  icon: Icon(Icons.payment), label: Text("ОПЛАТИТЬ"), color: Colors.blue,
                              textColor: Colors.white,
                              disabledColor: Colors.blue,
                              disabledTextColor: Colors.white,
                              padding: EdgeInsets.fromLTRB(50,10,50,10),
                              splashColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),

                                ),
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => QRgenerator()));
                                }
                            ),
                           Container(
                             child:Text('Кредитных средств на  $formattedDate - $creditbalance руб.', style: TextStyle(fontSize: 15.0,color: Colors.black87, ), textAlign: TextAlign.left,),
                             margin: EdgeInsets.fromLTRB(50,20,130,0),
                             alignment: Alignment(-1.0, 0.0),
                             width:MediaQuery.of(context).size.width - 180,

                           ),
                           FlatButton.icon(  icon: Icon(Icons.credit_card), label: Text("Обещаный платеж"), color: Colors.white,
                             textColor: Colors.redAccent,
                             disabledColor: Colors.white,
                             disabledTextColor: Colors.redAccent,
                             splashColor: Colors.white,
                             padding: EdgeInsets.fromLTRB(0,20,100,10),
                               onPressed: (){
                                 Navigator.push(context, MaterialPageRoute(builder: (context) => QRgenerator()));
                               }

                           ),

                 Row(
                     children: <Widget>[
                       Container(
                         child:Text('Логин: ', style: TextStyle(fontSize: 15.0,color: Colors.black87), textAlign: TextAlign.left,),
                         margin: EdgeInsets.fromLTRB(20,20,0,20),
                         alignment: Alignment(-1.0, 0.0),

                       ),
                       Container(
                         child:Text('$LoginF', style: TextStyle(fontSize: 15.0,color: Colors.black87, fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                         margin: EdgeInsets.fromLTRB(0,20,MediaQuery.of(context).size.width - 300,20),
                         alignment: Alignment(-1.0, 0.0),

                       ),
                       /*FlatButton.icon(icon: Icon(Icons.refresh), label: Text("Изменить"), color: Colors.blue,
                         textColor: Colors.redAccent,
                         //disabledColor: Colors.blue,
                         disabledTextColor: Colors.redAccent,
                         //padding: EdgeInsets.fromLTRB(0,20,100,10),
                         //splashColor: Colors.blueAccent,
                       ),*/
                     ]),
                         SizedBox(height: 5.0, width: MediaQuery.of(context).size.width - 30,
                           child: const DecoratedBox(
                           decoration: const BoxDecoration(
                           color: Colors.grey,
                             ),
                           ),),
                Container(
                    margin: EdgeInsets.fromLTRB(50,20,0,0),
                    alignment: Alignment(-1.0, 0.0),
                    child:Text('ФИО', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                Container(
                  margin: EdgeInsets.fromLTRB(50,0,10,10),
                  alignment: Alignment(-1.0, 0.0),
                  child:Text('$fio', style: TextStyle(fontSize: 20.0,color: Colors.black87))),

                Container(
                  margin: EdgeInsets.fromLTRB(50,20,0,0),
                  alignment: Alignment(-1.0, 0.0),
                  child:Text('Телефон', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                Container(
                  margin: EdgeInsets.fromLTRB(50,0,0,10),
                  alignment: Alignment(-1.0, 0.0),
                  child:Text('$phone', style: TextStyle(fontSize: 20.0,color: Colors.black87))),
                Container(
                  margin: EdgeInsets.fromLTRB(50,20,0,0),
                  alignment: Alignment(-1.0, 0.0),
                  child:Text('E-mail', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                Container(
                  margin: EdgeInsets.fromLTRB(50,0,0,10),
                  alignment: Alignment(-1.0, 0.0),
                  child:Text('$email', style: TextStyle(fontSize: 20.0,color: Colors.black87))),
                Container(
                  margin: EdgeInsets.fromLTRB(50,20,0,0),
                  alignment: Alignment(-1.0, 0.0),
                  child:Text('Дата создания учетной записи', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                Container(
                  margin: EdgeInsets.fromLTRB(50,0,0,10),
                  alignment: Alignment(-1.0, 0.0),
                  child:Text('$borndate', style: TextStyle(fontSize: 20.0,color: Colors.black87))),
                 SizedBox(height: 20.0),
                 Row(
                     children: <Widget>[
                       Container(
                             margin: EdgeInsets.fromLTRB(20,20,0,20),
                             alignment: Alignment(-1.0, 0.0),
                            child:Icon(Icons.language),),
                        Container(
                            margin: EdgeInsets.fromLTRB(5,20,0,20),
                            child:Text('Интернет', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                        ]),
                 SizedBox(height: 5.0, width: MediaQuery.of(context).size.width - 30,
                   child: const DecoratedBox(
                     decoration: const BoxDecoration(
                       color: Colors.grey,
                     ),
                   ),),
                 Container(
                     margin: EdgeInsets.fromLTRB(50,20,0,0),
                     alignment: Alignment(-1.0, 0.0),
                     child:Text('Тарифный план:', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                 Container(
                     margin: EdgeInsets.fromLTRB(50,0,0,10),
                     alignment: Alignment(-1.0, 0.0),
                     child:Text('$tpname', style: TextStyle(fontSize: 20.0,color: Colors.black87))),
                 Container(
                     margin: EdgeInsets.fromLTRB(50,20,0,0),
                     alignment: Alignment(-1.0, 0.0),
                     child:Text('Платеж:', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                 Container(
                     margin: EdgeInsets.fromLTRB(50,0,0,10),
                     alignment: Alignment(-1.0, 0.0),
                     child:Text('$periodicpay₽', style: TextStyle(fontSize: 20.0,color: Colors.black87))),
                 SizedBox(height: 20.0),
                 /*Row(
                     children: <Widget>[
                       Container(
                         margin: EdgeInsets.fromLTRB(20,20,0,20),
                         alignment: Alignment(-1.0, 0.0),
                         child:Icon(Icons.live_tv),),
                       Container(
                           margin: EdgeInsets.fromLTRB(5,20,0,20),
                           child:Text('Цифровое ТВ', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                     ]),
                 SizedBox(height: 5.0, width: MediaQuery.of(context).size.width - 30,
                   child: const DecoratedBox(
                     decoration: const BoxDecoration(
                       color: Colors.grey,
                     ),
                   ),),
                 Container(
                     margin: EdgeInsets.fromLTRB(50,20,0,0),
                     alignment: Alignment(-1.0, 0.0),
                     child:Text('Тарифный план:', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                 Container(
                     margin: EdgeInsets.fromLTRB(50,0,0,10),
                     alignment: Alignment(-1.0, 0.0),
                     child:Text('$TVsatus', style: TextStyle(fontSize: 20.0,color: Colors.black87))),
                 Container(
                     margin: EdgeInsets.fromLTRB(50,20,0,0),
                     alignment: Alignment(-1.0, 0.0),
                     child:Text('Платеж:', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                 Container(
                     margin: EdgeInsets.fromLTRB(50,0,0,10),
                     alignment: Alignment(-1.0, 0.0),
                     child:Text('$periodicpay₽', style: TextStyle(fontSize: 20.0,color: Colors.black87))),
                 SizedBox(height: 20.0),*/
                 Row(
                     children: <Widget>[
                       Container(
                         margin: EdgeInsets.fromLTRB(20,20,0,20),
                         alignment: Alignment(-1.0, 0.0),
                         child:Icon(Icons.extension),),
                       Container(
                           margin: EdgeInsets.fromLTRB(5,20,0,20),
                           child:Text('Подключеные услуги', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                     ]),
                 SizedBox(height: 5.0, width: MediaQuery.of(context).size.width - 30,
                   child: const DecoratedBox(
                     decoration: const BoxDecoration(
                       color: Colors.grey,
                     ),
                   ),),
                 SizedBox(height: 20.0),
                 ListView.builder(
                     physics: NeverScrollableScrollPhysics(),
                     shrinkWrap: true,
                     itemCount: servicename.length,
                     itemBuilder: (BuildContext context, int index) {
                       return Container(
                           //margin: EdgeInsets.fromLTRB(50,0,0,10),
                           //alignment: Alignment(-1.0, 0.0),
                          child: Column(
                                 children: <Widget>[
                                 Container(
                                     margin: EdgeInsets.fromLTRB(50,20,0,0),
                                     alignment: Alignment(-1.0, 0.0),
                                     child:Text('Услуга:', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                                 Container(
                                     margin: EdgeInsets.fromLTRB(50,0,10,5),
                                     alignment: Alignment(-1.0, 0.0),
                                     child:Text('${servicename[index]}', style: TextStyle(fontSize: 20.0,color: Colors.black87,fontWeight: FontWeight.bold,))),
                                   Container(
                                       margin: EdgeInsets.fromLTRB(50,0,0,0),
                                       alignment: Alignment(-1.0, 0.0),
                                       child:Text('Тарифный план:', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                                   Container(
                                       margin: EdgeInsets.fromLTRB(50,0,10,10),
                                       alignment: Alignment(-1.0, 0.0),
                                       child:Text('${tarifname[index]}', style: TextStyle(fontSize: 20.0,color: Colors.black87,fontWeight: FontWeight.bold,))),


                                   Container(
                                       margin: EdgeInsets.fromLTRB(50,5,0,0),
                                       alignment: Alignment(-1.0, 0.0),
                                       child:Text('Платеж:', style: TextStyle(fontSize: 15.0,color: Colors.black87))),

                                   Row(
                                    children: <Widget>[
                                    Container(
                                         margin: EdgeInsets.fromLTRB(50,0,0,10),
                                         padding: EdgeInsets.fromLTRB(0,8,0,0),
                                         alignment: Alignment(-1.0, 0.0),
                                         child:Text('${servicecost[index]}₽/мес.', style: TextStyle(fontSize: 20.0,color: Colors.black87,fontWeight: FontWeight.bold,))),
                                      FlatButton.icon(icon: Icon(Icons.settings), label: Text(""), color: Colors.blue,
                                        textColor: Colors.redAccent,
                                        //disabledColor: Colors.blue,
                                        disabledTextColor: Colors.redAccent,
                                        //padding: EdgeInsets.fromLTRB(0,20,100,10),
                                        //splashColor: Colors.blueAccent,
                                      ),
                                  ]),
                                   SizedBox(height: 5.0),
                                   SizedBox(height: 2.0, width: MediaQuery.of(context).size.width - 50,
                                     child: const DecoratedBox(
                                       decoration: const BoxDecoration(
                                         color: Colors.black,
                                       ),
                                     ),),
                                   SizedBox(height: 20.0),
                                ]
                          )
                       );
                     }

                 ),

                 SizedBox(height: 20.0),
                 FlatButton.icon(icon: Icon(Icons.exit_to_app), label: Text("Выход"), onPressed: LoOutProcedure),
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
                 SizedBox(height: 10.0),
                 Center(
                     child:Container(
                       child: Text('© 2008–${today.year.toString()} Skynetcom. Все права защищены.', style: TextStyle(fontSize: 13.0,color: Colors.black),
                         textAlign: TextAlign.center,),
                       //padding: EdgeInsets.fromLTRB(5,5,5,5),
                       alignment: Alignment(0.0, 0.0),
                     )
                 ),
                 GestureDetector(
                   onTap: () {
                     _persData();
                   },
                   child:Center(
                       child:Container(
                         child: Text('Обработка персональных данных.', style: TextStyle(fontSize: 13.0,color: Colors.blueGrey),
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

class FirstScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            brightness: Brightness.light,
          title: Image.asset('assets/logo1.png',  height: 50, fit:BoxFit.fill),
          centerTitle: true,
          backgroundColor: Color(0xFFffffff),
          actions: <Widget>[IconButton(icon: Icon(Icons.arrow_forward_ios), color: Colors.black, tooltip: 'Дальше', onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => QRgenerator()));
          })],//пример перехода в меню
        ),
        //body: TestHttp(url: 'https://skynetcom.koldashev.ru/test.php'),
        body: TestHttp(url: 'https://my.skynetcom.ru/api/v1/')
    );
  }
}


