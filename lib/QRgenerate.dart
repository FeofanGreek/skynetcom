import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slide_screen/YandexMoney.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';

import 'FirstScreen.dart';
import 'Tinkoff.dart';
import 'TreeScreen.dart';
//import 'main.dart';

String bestbefore,fio,phone,email,tpname,smotreshka;

class QRgenerator extends StatelessWidget {

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
        /*actions: <Widget>[IconButton(icon: Icon(Icons.arrow_forward_ios), tooltip: 'Дальше', onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ThreeScreen()));
        })],*///пример перехода в меню
      ),
      body: GenerateScreen(),
    );
  }
}

///////////
class GenerateScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "200";
  String _inputErrorText;
  final TextEditingController _textController =  TextEditingController();
  final TextEditingController _textControllerTrust =  TextEditingController();
  final TextEditingController _textControllerBank =  TextEditingController();
  final TextEditingController _textControllerTinkoff =  TextEditingController();
  /////

  String _url;
  //String bestbefore,fio,phone,email,tpname,smotreshka;

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

  @override
  void initState() {
    blocked = 0;
    accountnumber = 0;
    balance = 0.0;
    bestbefore = " ";
    creditbalance = 0.0;
    fio = "   ";
    phone = " ";
    email = " ";
    //borndate = 0;
    tpname = " ";
    periodicpay = 0.0;
    topay = 0.0;
    smotreshka = " ";
    _url = 'https://my.skynetcom.ru/api/v1/';
    sendFirstRequestPost();
    super.initState();
  }//initState

  //////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _contentWidget(),
    );
  }

  //звонок в ХД
  _CallToHelp() async {
    const url = "tel:88001005561";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Невозможно набрать номер $url';
    }
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
       return GestureDetector(
        onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
                },
        child: SingleChildScrollView(
          child: GestureDetector(// двигалка экрана
          onHorizontalDragUpdate: (dragUpdateDetails) {
        /*if(dragUpdateDetails.delta.dx < -0.5) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => QRgenerator()));//двигаем по умолчанию
        }*/
        if(dragUpdateDetails.delta.dx > 0.5) {
          Navigator.pop(context,
              CupertinoPageRoute(builder: (context) =>  ThreeScreen()));// двигать надо влево
        }
      },
           child:  Column(
                children: <Widget>[
                  Container(
                    child: Text("Оплата", style: TextStyle(fontSize: 20.0,color: Colors.blue)),
                    padding: EdgeInsets.all(10.0),
                  ),
                  Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(20,20,0,20),
                          alignment: Alignment(-1.0, 0.0),
                          child:Icon(Icons.credit_card),),
                        Container(
                            margin: EdgeInsets.fromLTRB(5,20,0,20),
                            child:Text('Банковская карта', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                      ]),
                  SizedBox(height: 5.0, width: MediaQuery.of(context).size.width - 30,
                    child: const DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),),
                  SizedBox(height: 10.0),
                  Container(
                    padding: EdgeInsets.fromLTRB(20,0,10,0),
                    child:Text('Рекомендуем оплатить $_dataString руб.', style: TextStyle(fontSize: 12.0,color: Colors.black87)),
                  ),
                  Container(
                      child:TextFormField( inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                      ], keyboardType: TextInputType.number, controller: _textControllerTinkoff, decoration: InputDecoration(hintText: "Cумма платежа", focusedBorder: OutlineInputBorder(
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
                      ),), /*validator: (value){if (value.isEmpty) return 'Введите сумму';}, onSaved: (value){_PostPassword = value;},*/ autovalidate: true,),
                      padding: EdgeInsets.fromLTRB(40,10,40,5)
                  ),
                  SizedBox(height: 10.0),
                  RaisedButton.icon(onPressed: (){if(_textControllerTinkoff.text != "") {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            tinkoff(sumBank: _textControllerTinkoff.text, //YM(sumBank: _textControllerBank.text,
                                custNum: accountnumber)));
                  }}, icon: Icon(Icons.payment), label: Text("Оплатить"),color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor: Colors.blue,
                    disabledTextColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(50,10,50,10),
                    splashColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),

                    ),),
                  SizedBox(height: 10.0),
                  Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(20,20,0,20),
                          alignment: Alignment(-1.0, 0.0),
                          child:Icon(Icons.payments_outlined),),
                        Container(
                            margin: EdgeInsets.fromLTRB(5,20,0,20),
                            child:Text('Яндекс деньги', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                      ]),
                  SizedBox(height: 5.0, width: MediaQuery.of(context).size.width - 30,
                    child: const DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),),
                  SizedBox(height: 10.0),
                  Container(
                    padding: EdgeInsets.fromLTRB(20,0,10,0),
                    child:Text('Рекомендуем оплатить $_dataString руб.', style: TextStyle(fontSize: 12.0,color: Colors.black87)),
                  ),
                  Container(
                      child:TextFormField( inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                      ], keyboardType: TextInputType.number, controller: _textControllerBank, decoration: InputDecoration(hintText: "Cумма платежа", focusedBorder: OutlineInputBorder(
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
                      ),), /*validator: (value){if (value.isEmpty) return 'Введите сумму';}, onSaved: (value){_PostPassword = value;},*/ autovalidate: true,),
                      padding: EdgeInsets.fromLTRB(40,10,40,5)
                  ),
                  SizedBox(height: 10.0),
                  RaisedButton.icon(onPressed: (){if(_textControllerBank.text != "") {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            YM(sumBank: _textControllerBank.text,
                                custNum: accountnumber)));
                  }}, icon: Icon(Icons.payment), label: Text("Оплатить"),color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor: Colors.blue,
                    disabledTextColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(50,10,50,10),
                    splashColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),

                    ),),
                  SizedBox(height: 10.0),
                  Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(20,20,0,20),
                          alignment: Alignment(-1.0, 0.0),
                          child:Icon(Icons.thumb_up),),
                        Container(
                            margin: EdgeInsets.fromLTRB(5,20,0,20),
                            child:Text('Обещаный платеж', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                      ]),
                  SizedBox(height: 5.0, width: MediaQuery.of(context).size.width - 30,
                    child: const DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),),
                  SizedBox(height: 10.0),

                  Container(
                      child:TextFormField( inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                      ], keyboardType: TextInputType.number, controller: _textControllerTrust, decoration: InputDecoration(hintText: "Cумма платежа", focusedBorder: OutlineInputBorder(
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
                      ),), /*validator: (value){if (value.isEmpty) return 'Пароль не введен';}, onSaved: (value){_PostPassword = value;},*/ autovalidate: true,),
                      padding: EdgeInsets.fromLTRB(40,10,40,5)
                  ),
                  SizedBox(height: 10.0),
                  RaisedButton.icon(onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    setState((){
                      _dataString = _textController.text;
                      _inputErrorText = null;
                    });
                  }, icon: Icon(Icons.event_available), label: Text("Активировать"),color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor: Colors.blue,
                    disabledTextColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(50,10,50,10),
                    splashColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),

                    ),),
                  SizedBox(height: 30.0),
                  Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(20,20,0,20),
                          alignment: Alignment(-1.0, 0.0),
                          child:Icon(Icons.filter_center_focus),),
                        Container(
                            margin: EdgeInsets.fromLTRB(5,20,0,20),
                            child:Text('Платеж по QR-коду', style: TextStyle(fontSize: 15.0,color: Colors.black87))),
                      ]),
                  SizedBox(height: 5.0, width: MediaQuery.of(context).size.width - 30,
                    child: const DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),),
                  SizedBox(height: 10.0),
                  Container(
                    padding: EdgeInsets.fromLTRB(20,0,10,0),
                    child:Text('Рекомендуем оплатить $_dataString руб.', style: TextStyle(fontSize: 12.0,color: Colors.black87)),
                  ),
                  Container(
                    child:TextFormField(
                      inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                    ], keyboardType: TextInputType.number, controller: _textController, decoration: InputDecoration(hintText: "Cумма платежа", focusedBorder: OutlineInputBorder(
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
                  ),), /*validator: (value){if (value.isEmpty) return 'Пароль не введен';}, onSaved: (value){_PostPassword = value;},*/ autovalidate: true,),
                        padding: EdgeInsets.fromLTRB(40,10,40,5)
                        ),
                  SizedBox(height: 10.0),
                  RaisedButton.icon(onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    setState((){
                      _dataString = _textController.text;
                      _inputErrorText = null;
                    });
                        }, icon: Icon(Icons.done_all), label: Text("Сформировать"),color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor: Colors.blue,
                    disabledTextColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(50,10,50,10),
                    splashColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),

                    ),),
                    SizedBox(height: 10.0),
                    Container(
                      padding: EdgeInsets.fromLTRB(20,0,10,0),
                      child:Text('Сканируйте полученый QR-код приложением вашего банка или в банкомате и пополните баланс лицевого счета.', style: TextStyle(fontSize: 15.0,color: Colors.black87)),
                            ),
                    Center(
                      child: RepaintBoundary(
                        key: globalKey,
                        child: QrImage(
                          data: "ST00012|Name=ООО ПВОНЕТ|PersonalAcc=40702810100000166355|BankName=ПАО ПРОМСВЯЗЬБАНК|BIC=044525555|CorrespAcc=30101810400000000555|PayeуINN=5003076310|LastName="+fio.split(" ")[0]+"|FirstName="+fio.split(" ")[1]+"|MiddleName="+fio.split(" ")[2]+"|Purpose=Оплата информационных услуг. Личный счет $accountnumber|PayerAddress=0|Sum="+_dataString+"00|persAcc=$accountnumber|personalAccount=$accountnumber",
                          size: 0.5 * bodyHeight,
                        ),
                      ),
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
              ))));
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

      //_status = response.statusCode;
      Map<String, dynamic> user = jsonDecode(response.body);

      /*if ((user['fio'] == 'Неверный логин') && (LoginF != "0")) {LoOutProcedure();//если введенный пароль неверен, разлогиниваемся
      }*/

    blocked = user['blocked'];
    //var blocked = new DateTime.fromMillisecondsSinceEpoch(user['blocked']*1000);
    print(blocked);
    //if(blocked.isAfter(DateTime.now())){TextBlocked = 'Услуги активны'; ColorBlocked = [107,138,71];}
    if(blocked == 4294967295){TextBlocked = 'Услуги активны'; ColorBlocked = [107,138,71];}
    accountnumber = user['accountnumber'];
    balance = user['balance'];
    bestbefore = user['bestbefore'];
    print(bestbefore);
    creditbalance = user['creditbalance'].toDouble();
    fio = user['fio']+"  ";
    phone = user['phone'];
    email = user['email'];
    borndate = DateFormat('dd.MM.yyyy').format(new DateTime.fromMillisecondsSinceEpoch(user['createdate']*1000));
    tpname = user['tpname'];
    periodicpay = user['periodicpay'].toDouble();
    topay = user['topay'].toDouble();
    if(topay > 0.0) {_dataString = topay.toString();}
    //smotreshka = user['smotreshka'];
    //if(smotreshka == "0") {TVsatus = "ЦИФРОВОЕ ТВ НЕ ПОДКЛЮЧЕНО";}
    //работаем с массивом из JSON
    for(int i=0; i < user['services'].length; i++){
    //print(user['turnonservices'][i]);
    servicename.add(user['services'][i]['service_name']);
    tarifname.add(user['services'][i]['tariff_name']);
    servicecost.add(user['services'][i]['cost'].toDouble());

      }

    } catch (error) {FirstScreen();}
    setState(() {});//reBuildWidget
  }

}


