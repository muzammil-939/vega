import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vega/screens/home.dart';
import '../providers/firebase_auth.dart';

class OTPInputScreen extends ConsumerStatefulWidget {
  List<TextEditingController> otpControllers = List.generate(
    6, // Replace with the number of OTP fields
    (index) => TextEditingController(),
  );
  OTPInputScreen(this.otpControllers, {super.key});

  @override
  _OTPInputScreenState createState() => _OTPInputScreenState();
}

class _OTPInputScreenState extends ConsumerState<OTPInputScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 24),
        Text(
          "One Time Password",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: screenHeight * 0.015,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.otpControllers.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 40,
                  child: TextFormField(
                    controller: widget.otpControllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 &&
                          index < widget.otpControllers.length - 1) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: screenHeight * 0.01,
        ),
        Container(
          height: screenHeight * 0.05,
          width: screenWidth * 0.28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(37, 152, 158, 100),
                Color.fromRGBO(201, 233, 236, 50),
                Color.fromRGBO(122, 194, 199, 100),
                Color.fromRGBO(37, 152, 158, 100),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(107),
          ),
          child: ElevatedButton(
            onPressed: () async {
              String smsCode = widget.otpControllers
                  .map((controller) => controller.text)
                  .join();
              if (smsCode.length == widget.otpControllers.length) {
                try {
                  await ref
                      .read(phoneAuthProvider.notifier)
                      .signInWithPhoneNumber(smsCode, ref);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("OTP Verified Successfully!")),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to verify OTP: $e")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter the complete OTP.")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(107),
              ),
            ),
            child: Text(
              'Verify',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: const Color(0xff025253),
              ),
            ),
          ),
        ),
        SizedBox(
          height: screenHeight * 0.05,
        ),
      ],
    );
  }
}
