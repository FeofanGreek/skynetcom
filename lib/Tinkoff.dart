import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'QRgenerate.dart';

class tinkoff extends StatefulWidget {

  final String sumBank;
  final int custNum;
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  tinkoff({
    @required this.custNum,
    @required this.sumBank,
  });

  //final url;
  //WebViewContainer();
  @override
  createState() => _tinkoff(numbr:custNum, sum: sumBank);


}


class _tinkoff extends State <tinkoff> {
  final String sum;
  final int numbr;

  _tinkoff({
    @required this.sum,
    @required this.numbr,
  });

  final _key = UniqueKey();
  num _stackToView = 1;

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  //final String sumBank;
  //final String custNum;
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Image.asset('assets/logo1.png',  height: 50, fit:BoxFit.fill),
          centerTitle: true,
          backgroundColor: Color(0xFFffffff),
          /*actions: <Widget>[IconButton(icon: Icon(Icons.arrow_forward_ios), tooltip: 'Дальше', onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => SecondScreen()));
          })],*///пример перехода в меню
        ),
        body:IndexedStack(
            index: _stackToView,
            children: [

              WebView(
                key: _key,
                initialUrl: new Uri.dataFromString(_loadHTML(), mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString(),
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);

                },onPageFinished: _handleLoad,),
              Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ]));
  }

  String _loadHTML() {
    var stringBody = '<html><body style="font-size: xx-large;">'+
        '<style>.tinkoffPayRow{display:block;margin:1%;width:160px;}<\/style>'+
        '<script src="https://securepay.tinkoff.ru/html/payForm/js/tinkoff_v2.js"><\/script>'+

        '<form name="TinkoffPayForm" onsubmit="pay(this); return false;" id="f">'+
        '<input type="hidden" name="terminalkey" value="1605712709095">'+
        '<input type="hidden" name="frame" value="true">'+
        '<input type="hidden" name="language" value="ru">'+
        '<input type="hidden" name="amount" required value="$sum">'+
        '<input class="tinkoffPayRow" type="hidden" placeholder="Номер заказа" name="order">'+
        '<input type="hidden" name="description" value="Aбонентская плата ЛС '+numbr.toString()+'">'+
        '<input type="hidden" name="name" value="$fio">'+
        '<input type="hidden" name="email" value="${email!='Неизвестен'?email:''}">'+
        '<input type="hidden" name="phone" value="$phone">'+
        '<input class="tinkoffPayRow" type="hidden" name="DATA" value="{&quot;accountID&quot;: &quot;${numbr.toString()}&quot;}">'+
        '<input type="submit" style="display:none; width: 1px;  height: 1px;" id="b">'+
       '<\/form>'+
        '<script>'+
        'setTimeout(() => document.getElementById("b").click(), 2000);'+
        '<\/script>'+
        '<center>Загрузка модуля оплаты<\/center>'+
        //'<img src="progress.gif">'+
       '<\/body><\/html>';
    return stringBody;
  }

}


