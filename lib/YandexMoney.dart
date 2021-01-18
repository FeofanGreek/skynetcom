import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class YM extends StatefulWidget {

  final String sumBank;
  final int custNum;
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  YM({
    @required this.custNum,
    @required this.sumBank,
  });

  //final url;
  //WebViewContainer();
  @override
  createState() => _YM(numbr:custNum, sum: sumBank);


}


class _YM extends State <YM> {
  final String sum;
  final int numbr;

  _YM({
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
          initialUrl: new Uri.dataFromString(_loadHTML(), mimeType: 'text/html').toString(),
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
    return '<html><body onload="document.f.submit();"><form id="f" name="f" method="post" action="https://money.yandex.ru/eshop.xml"><input type="hidden" name="scid" value="8563"><input type="hidden" name="ShopID" value="17009"><input type="hidden" name="CustomerNumber" value="'+numbr.toString()+'"><input type="hidden" name="Sum" class="input" value="'+sum+'"></form></body></html>';
  }

}


