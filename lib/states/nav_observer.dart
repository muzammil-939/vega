import 'package:flutter/material.dart';

class ChatNavigatorObserver extends NavigatorObserver {
  final VoidCallback onUserExit;

  ChatNavigatorObserver(this.onUserExit);

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Invoke the callback when the route is popped
    onUserExit();
  }
}
