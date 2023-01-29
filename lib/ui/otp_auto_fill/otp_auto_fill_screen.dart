import 'package:flutter/material.dart';
import 'package:otp_autofill/otp_autofill.dart';



///---------------
/// is will work when your sms pattern is like your code is 123456
/// --------------

class OtpAutoFllScreen extends StatefulWidget {
  const OtpAutoFllScreen({Key? key}) : super(key: key);

  @override
  _OtpAutoFllScreenState createState() => _OtpAutoFllScreenState();
}

class _OtpAutoFllScreenState extends State<OtpAutoFllScreen> {
  final scaffoldKey = GlobalKey();
  late OTPTextEditController controller;
  late OTPInteractor _otpInteractor;

  @override
  void initState() {
    super.initState();
    _otpInteractor = OTPInteractor();
    _otpInteractor
        .getAppSignature()
    //ignore: avoid_print
        .then((value) => print('signature - $value'));

    controller = OTPTextEditController(
      codeLength: 5,
      //ignore: avoid_print
      onCodeReceive: (code) => print('Your Application receive code - $code'),
      otpInteractor: _otpInteractor,
    )..startListenUserConsent(
          (code) {
        final exp = RegExp(r'(\d{6})');
        return exp.stringMatch(code ?? '') ?? '';
      },
     
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await controller.stopListen();
    super.dispose();
  }
}
