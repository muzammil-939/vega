import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vega/screens/home.dart';
import '../providers/firebase_auth.dart';
import '../sign_in/fb_sign_in.dart';

class LoginScreen extends ConsumerWidget {
  final phoneController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneAuthState = ref.watch(phoneAuthProvider);
    final phoneAuthNotifier = ref.read(phoneAuthProvider.notifier);
    // Getting the screen size using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
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
              bottom: 0,
              child: Container(),
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
                    controller: phoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Perform some action
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
                          onPressed: () {
                            phoneAuthNotifier
                                .verifyPhoneNumber(phoneController.text);

                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              builder: (BuildContext context) {
                                return Container(
                                  height: screenHeight * 0.5,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xffc9e9ec),
                                        Color(0xffffffff),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: screenHeight * 0.07),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 40),
                                            child: Text(
                                              "One Time Password",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.045,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 40,
                                              right: 70,
                                            ),
                                            child: Text(
                                              "An OTP has been sent to the phone number ending with 78",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 30,
                                          bottom: 45,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildCircularContainer(),
                                            SizedBox(width: screenWidth * 0.04),
                                            _buildCircularContainer(),
                                            SizedBox(width: screenWidth * 0.04),
                                            _buildCircularContainer(),
                                            SizedBox(width: screenWidth * 0.04),
                                            _buildCircularContainer(),
                                            SizedBox(width: screenWidth * 0.04),
                                            Text(
                                              "Resend in 59s",
                                              style: TextStyle(
                                                color: const Color(0xff27999A),
                                                fontSize: screenWidth * 0.04,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.85,
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                // Perform some action
                                              },
                                              child: Text(
                                                "Change Number?",
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  color: const Color.fromRGBO(
                                                      39, 153, 154, 100),
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      const Color.fromRGBO(
                                                          39, 153, 154, 100),
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
                                                    Color.fromRGBO(
                                                        37, 152, 158, 100),
                                                    Color.fromRGBO(
                                                        201, 233, 236, 50),
                                                    Color.fromRGBO(
                                                        122, 194, 199, 100),
                                                    Color.fromRGBO(
                                                        37, 152, 158, 100),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(107),
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const HomePage()),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            107),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Login',
                                                    style: TextStyle(
                                                      fontSize:
                                                          screenWidth * 0.05,
                                                      color: const Color(
                                                          0xff025253),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
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
                  SizedBox(
                    height: screenHeight * 0.025,
                  ),
                  Text(
                    "Or Login with",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.025,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Perform some action
                          },
                          child: Container(
                            height: screenHeight * 0.05,
                            width: screenWidth * 0.35,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black12,
                                width: 3,
                              ),
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
                          onTap: () =>
                              SignInMethods.signInWithFacebook(context),
                          child: Container(
                            height: screenHeight * 0.05,
                            width: screenWidth * 0.35,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black12,
                                width: 3,
                              ),
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
                      ]),
                  SizedBox(
                    height: screenHeight * 0.025,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Perform some action
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
  }
}

// OTP dialog circles
Widget _buildCircularContainer() {
  return Container(
    width: 40,
    height: 40,
    decoration: const BoxDecoration(
      color: Color(0xffBDE2E4),
      shape: BoxShape.circle,
    ),
  );
}
