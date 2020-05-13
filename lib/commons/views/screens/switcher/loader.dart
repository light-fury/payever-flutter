import 'dart:async';

import '../../../utils/utils.dart';

enum LoadState { LOADED, NOT_LOADED }

abstract class LoadStateListener {
  void onLoadStateChanged(LoadState state);
}

// A naive implementation of Observer/Subscriber Pattern. Will do for now.
class LoadStateProvider {
  static final LoadStateProvider _instance = new LoadStateProvider.internal();
  List<LoadStateListener> _subscribers;

  factory LoadStateProvider() => _instance;

  LoadStateProvider.internal() {
    _subscribers = new List<LoadStateListener>();
    initState();
  }

  void initState() async {
    var isLoggedIn = GlobalUtils.isLoaded;

    if (isLoggedIn)
      notify(LoadState.LOADED);
    else
      notify(LoadState.NOT_LOADED);
    GlobalUtils.isDashboardLoaded = false;
  }

  void subscribe(LoadStateListener listener) {
    _subscribers.add(listener);
  }

  void dispose(LoadStateListener listener) {
    _subscribers = [];
  }

  Future<bool> notify(LoadState state) async {
    _subscribers.forEach((LoadStateListener s) {
      s.onLoadStateChanged(state);
    });

    return true;
  }
}
