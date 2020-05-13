import 'dart:async';

enum AuthState { LOGGED_IN, LOGGED_OUT }

abstract class AuthStateListener {
  void onAuthStateChanged(AuthState state);
}

// A naive implementation of Observer/Subscriber Pattern. Will do for now.
class AuthStateProvider {
  static final AuthStateProvider _instance = AuthStateProvider.internal();
  List<AuthStateListener> _subscribers;

  factory AuthStateProvider() => _instance;

  AuthStateProvider.internal() {
    _subscribers = List<AuthStateListener>();
    initState();
  }

  void initState() async {}

  void subscribe(AuthStateListener listener) {
    _subscribers.add(listener);
  }

  void dispose(AuthStateListener listener) {
    _subscribers = [];
  }

  Future<bool> notify(AuthState state) async {
    _subscribers.forEach((AuthStateListener s) {
      s.onAuthStateChanged(state);
    });

    return true;
  }
}
