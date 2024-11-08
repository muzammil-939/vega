import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vega/screens/room.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: screenHeight * 0.46,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffffffff),
                  Color(0xffBDE2E4),
                ],
                stops: [
                  0.8,
                  1.0,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Image.asset(
                  'assets/images/most_popular_title.png',
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Positioned(
            top: 120,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 25),
                  _mostPopularGames(),
                  const SizedBox(width: 25),
                  _mostPopularGames(),
                  const SizedBox(width: 25),
                  _mostPopularGames(),
                  const SizedBox(width: 25),
                  _mostPopularGames(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.54,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
                gradient: LinearGradient(
                  colors: [
                    Color(0xffffffff),
                    Color(0xffBDE2E4),
                  ],
                  stops: [
                    0.8,
                    1.0,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, left: 25),
                  child: Row(
                    children: [
                      Container(
                        width: screenWidth * 0.45,
                        height: screenHeight * 0.24,
                        decoration: BoxDecoration(
                            color: Color(0x33d5c994),
                            borderRadius: BorderRadius.circular(25)),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Image.asset(
                                'assets/images/Rectangle_2.png',
                                width: screenWidth * 0.42,
                                height: screenWidth * 0.3,
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.33,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Default Room"),
                                  Text(
                                    "#1234",
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: screenWidth * 0.35,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image(
                                        image: AssetImage(
                                            'assets/images/Rectangle_3.png'),
                                      ),
                                      Icon(Icons.person),
                                      Text("1/4"),
                                    ],
                                  ),
                                  Container(
                                    height: 30,
                                    width: 60,
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Room()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(107),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Join',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff025253),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Add user info at the bottom of the screen
          // Positioned(
          //   bottom: 40, // Position the user info at the bottom
          //   left: 20,
          //   right: 20,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       // Display user's display name
          //       Text(
          //         user?.displayName ?? 'No Name Available',
          //         style: const TextStyle(
          //           fontSize: 18,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       const SizedBox(height: 8),
          //       // Display user's email
          //       Text(
          //         user?.email ?? 'No Email Available',
          //         style: const TextStyle(
          //           fontSize: 16,
          //           color: Colors.black54,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

Widget _mostPopularGames() {
  return SizedBox(
    height: 300,
    child: Stack(
      children: [
        Center(
          child: Container(
            height: 200,
            width: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFCCE7E8), // Gradient color (Light Blue)
                  Color(0xffffffff), // Gradient color (White)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4), // Shadow position
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Game Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '4.5/5',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videogame_asset,
                        color: Colors.black54,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '12.7k',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 40,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(
              Icons.image,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 30,
          child: Container(
            height: 30,
            width: 102,
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
                // Perform some action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(107),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Center(
                child: Text(
                  'Play',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff025253),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}