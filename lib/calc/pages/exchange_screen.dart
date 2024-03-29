import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fx_crystal_ball/constants.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_model.dart';


class ExchangeScreen extends StatefulWidget {
  static const String id = 'exchange_screen';

  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String messageText;

  @override
  void initState(
      ) {
    super.initState(
    );

    getCurrentUser(
    );
  }

  void getCurrentUser(
      ) async {
    try {
      final user = await _auth.currentUser(
      );
      if (user != null) {
        loggedInUser = user;
      }
    }
    catch (e) {
      print(
          e
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Exchange();
  }
}



class Exchange extends StatefulWidget {
  @override
  createState() => ExchangeState();
}

class ExchangeState extends State<Exchange> {
  String currencyFrom = 'USD';
  String currencyTo = 'CAD';
  String amount = '';
  String result = '';
  final String url = 'https://api.ratesapi.io/api/latest';

  Future fetchData(String currencyFrom, String currencyTo) async {
    final response = await http.get('$url?base=${currencyFrom}&symbols=${currencyTo}');


    if (response.statusCode == 200) {
      var data = ExchangeModel.fromJson(json.decode(response.body));
      var rate = data.rates;
      rate.forEach(iterateMapEntry);
    } else if (response.statusCode == 400) {
      var data = ExchangeModel.fromJson(json.decode(response.body));
      var error = data.error;
      updateResult(error);

    } else {
      throw Exception('API calls are over the limit!');
    }
  }

  void iterateMapEntry(key, value) {
    updateResult((value * double.parse(amount)).toStringAsFixed(4));
  }

  void updateAmount(value) {
    setState(() {
      amount = value;
    });
  }

  void updateCurrencyFrom(value) {
    setState(() {
      currencyFrom = value;
      result = '';
    });
  }

  void updateCurrencyTo(value) {
    setState(() {
      currencyTo = value;
      result = '';
    });
  }

  void handleClick() {
    if (amount.length > 0) {
      fetchData(currencyFrom, currencyTo,);
    }
  }

  void updateResult(value) {
    setState(() {
      result = value;
    });
  }

  void goTo(page) {
    Navigator.pushNamed(context, '/$page');
  }

  @override
  Widget build(BuildContext context) {

    final currencies = [
      new DropdownMenuItem<String>(value: 'EUR', child: Text('EUR')),
      new DropdownMenuItem<String>(value: 'USD', child: Text('USD')),
      new DropdownMenuItem<String>(value: 'CHF', child: Text('CHF')),
      new DropdownMenuItem<String>(value: 'CAD', child: Text('CAD')),
      new DropdownMenuItem<String>(value: 'AUD', child: Text('AUD'))


    ].toList();

    Widget resultChild;

    if (result != '') {
      resultChild = Container(
        margin: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
        decoration: BoxDecoration(color: Colors.black12),
        height: 50.0,
        alignment: Alignment(0.0, 0.0),
        child: Text(result, style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold
        )),
      );
    } else {
      resultChild = Container();
    }

    var textField = Row(
      children: [
        Expanded(
          child: TextField(
              decoration: InputDecoration(
                  labelText: 'Type amount'
              ),
              onChanged: (value) => updateAmount(value)
          ),
        )
      ],
    );

    var dropDowns = Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(0.0, 20.0, 40.0, 0.0),
            child: DropdownButton(
              value: currencyFrom,
              items: currencies,
              onChanged: (value) {
                updateCurrencyFrom(value);
              },
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(40.0, 20.0, 0.0, 0.0),
            child: DropdownButton(
              value: currencyTo,
              items: currencies,
              onChanged: (value) {
                updateCurrencyTo(value);
              },
            ),
          ),
        )
      ],
    );

    var message = Row(
      children: [
        Expanded(
            child: resultChild
        )
      ],
    );

    var button = Row(
      children: [
        Expanded(
            child: Container(
                child: RaisedButton(
                    child: Text('Calculate'),
                    color: Colors.redAccent,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 30.0),
                    onPressed: () => handleClick()
                )
            )
        )
      ],
    );

    return Scaffold(
        appBar: AppBar(
            title: Text('Simple Exchange'),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () => goTo('credits')
              )
            ]
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                textField,
                dropDowns,
                message
              ],
            )
        ),
        bottomNavigationBar: button
    );
  }
}