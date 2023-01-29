import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:autofill_otp_demo/ui/home/home_screen.dart';
import 'package:autofill_otp_demo/utils/common_utils.dart';
import 'package:autofill_otp_demo/utils/const.dart';
import 'package:autofill_otp_demo/utils/widget/border_box.dart';
import 'package:autofill_otp_demo/utils/widget/white_container.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpScreenUsingAltSmsAutoFill extends StatefulWidget {
  final String phone;

  const OtpScreenUsingAltSmsAutoFill({Key? key, required this.phone})
      : super(key: key);

  @override
  State<OtpScreenUsingAltSmsAutoFill> createState() =>
      _OtpScreenUsingAltSmsAutoFillState();
}

class _OtpScreenUsingAltSmsAutoFillState
    extends State<OtpScreenUsingAltSmsAutoFill> {
  String otpCode = "";
  bool isLoaded = false;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> initSmsListener() async {
    String? comingSms;
    try {
      comingSms = await AltSmsAutofill().listenForSms;
    } on PlatformException {
      comingSms = 'Failed to get Sms.';
    } catch (e, s) {
      showLog("Error $e , StackTrace $s");
    }
    if (!mounted) return;

    setState(() {
      otpCode = comingSms ?? "";
    });
  }

  @override
  void dispose() {
    AltSmsAutofill().unregisterListener();
    super.dispose();
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      initSmsListener();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      color: const Color(0xFF7D84E0),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: isLoaded ? Colors.white : const Color(0xFF7D84E0),
          body: isLoaded
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 50),
                            child: Container(
                              height: 50,
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          WhiteContainer(
                            headerText: "Enter OTP",
                            labelText:
                                "OTP has been successfully sent to your \n ${widget.phone}",
                            child: SizedBox(
                              height: 70,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  PinFieldAutoFill(
                                    currentCode: otpCode,
                                    decoration: const BoxLooseDecoration(
                                      radius: Radius.circular(12),
                                      strokeColorBuilder: FixedColorBuilder(
                                        Color(0xFF7D84E0),
                                      ),
                                    ),
                                    codeLength: 6,
                                    onCodeChanged: (code) {
                                      showLog("OnCodeChanged : $code");
                                      otpCode = code.toString();
                                    },
                                    onCodeSubmitted: (val) {
                                      showLog("OnCodeSubmitted : $val");
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            color: Colors.white,
            child: GestureDetector(
              onTap: () async {
                showLog("OTP: $otpCode");
                setState(() {
                  isLoaded = true;
                });
                try {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: CommonUtils.verify, smsCode: otpCode);
                  await auth.signInWithCredential(credential);
                  setState(() {
                    isLoaded = false;
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                } catch (e) {
                  setState(() {
                    isLoaded = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Wrong OTP! Please enter again"),
                    ),
                  );
                  showLog("Wrong OTP");
                }
              },
              child: const BorderBox(
                margin: false,
                color: Color(0xFF7D84E0),
                height: 50,
                child: Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
