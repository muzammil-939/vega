import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vega/providers/loader.dart';
import 'package:vega/screens/home.dart';
import '../providers/firebase_auth.dart';
import '../states/fb_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController(text: "+91");
  final List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());

  @override
  void dispose() {
    phoneController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Consumer(
      builder: (context, ref, child) {
        final phoneAuthNotifier = ref.read(phoneAuthProvider.notifier);
        var loader = ref.watch(loadingProvider);
        var codesent = ref.watch(codeSent);

        return Scaffold(
          body: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Stack(
              children: [
                // Background and design assets
                Positioned(
                  right: screenWidth * 0.02,
                  top: screenHeight * 0.05,
                  child: Image.asset('assets/images/Ellipse2_login.png'),
                ),
                Positioned(
                  left: screenWidth * 0.15,
                  top: screenHeight * 0.1,
                  child: Image.asset('assets/images/Ellipse1_login.png'),
                ),
                Positioned(
                  left: screenWidth * 0.25,
                  top: screenHeight * 0.08,
                  child: Image.asset('assets/images/Vega_png1.png'),
                ),
                Positioned(
                  left: screenWidth * 0.2,
                  top: screenHeight * 0.3,
                  child: Image.asset('assets/images/join_the_fun.png'),
                ),
                Positioned(
                  top: screenHeight * 0.4,
                  left: screenWidth * 0.45,
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.48,
                  right: screenWidth * 0.05,
                  left: screenWidth * 0.05,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mobile Number",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextField(
                        cursorColor: Colors.teal,
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          hintText: 'Enter your 10-digit mobile number',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: const BorderSide(
                              color: Colors.teal,
                              width: 2.0,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (!value.startsWith("+91")) {
                            phoneController.text = "+91";
                            phoneController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: phoneController.text.length),
                            );
                          }
                        },
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Forgot number action
                            },
                            child: Text(
                              "forgot number?",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: const Color.fromRGBO(39, 153, 154, 100),
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    const Color.fromRGBO(39, 153, 154, 100),
                                decorationThickness: 2.0,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            height: screenHeight * 0.06,
                            width: screenWidth * 0.35,
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
                              onPressed: loader == true
                                  ? null
                                  : () async {
                                      String phoneNumber =
                                          phoneController.text.trim();
                                      if (phoneNumber.startsWith("+91") &&
                                          phoneNumber.length == 13 &&
                                          RegExp(r'^[6-9]\d{9}$').hasMatch(
                                              phoneNumber.substring(3))) {
                                        await phoneAuthNotifier
                                            .verifyPhoneNumber(phoneNumber, ref,
                                                () {
                                          setState(() {
                                            codesent = true;
                                          });
                                        });
                                        if (codesent) {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return buildOtpModal(
                                                  context,
                                                  screenHeight,
                                                  screenWidth,
                                                  ref);
                                            },
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Please enter a valid 10-digit mobile number after +91.'),
                                          ),
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
                              child: FittedBox(
                                child: loader == true
                                    ? CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        'SEND OTP',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.045,
                                          color: const Color(0xff025253),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (codesent == true)
                        buildOtpModal(context, screenHeight, screenWidth, ref),
                      SizedBox(height: screenHeight * 0.025),
                      Text(
                        "Or Login with",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Google sign-in action
                            },
                            child: Container(
                              height: screenHeight * 0.05,
                              width: screenWidth * 0.35,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black12, width: 3),
                                borderRadius: BorderRadius.circular(107),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.02),
                                child: SvgPicture.asset(
                                  'assets/images/google_logo.svg',
                                  width: screenWidth * 0.08,
                                  height: screenHeight * 0.04,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            // => SignInMethods.signInWithFacebook(context),
                            child: Container(
                              height: screenHeight * 0.05,
                              width: screenWidth * 0.35,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black12, width: 3),
                                borderRadius: BorderRadius.circular(107),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.02),
                                child: SvgPicture.asset(
                                  'assets/images/facebook_logo.svg',
                                  width: screenWidth * 0.08,
                                  height: screenHeight * 0.04,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Sign-up action
                          },
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(2, 82, 83, 1),
                              decorationColor:
                                  const Color.fromRGBO(39, 153, 154, 100),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildOtpModal(BuildContext context, double screenHeight,
      double screenWidth, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffc9e9ec), Color(0xffffffff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: screenHeight * 0.07),
            Text(
              "One Time Password",
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  otpControllers.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 40,
                      child: TextFormField(
                        controller: otpControllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '', // Hide the counter
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 &&
                              index < otpControllers.length - 1) {
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
            // Remaining OTP Modal code...

            Container(
              height: screenHeight * 0.06,
              width: screenWidth * 0.35,
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
                onPressed: () {
                  String smsCode = otpControllers
                      .map((controller) => controller.text)
                      .join();
                  ref
                      .read(phoneAuthProvider.notifier)
                      .signInWithPhoneNumber(smsCode, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(107),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      color: const Color(0xff025253),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
