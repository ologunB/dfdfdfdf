import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/cupertino.dart';

import 'ably_service.dart';

class RealtimeService extends ChangeNotifier {
  final AblyService ablyService;
  final ably.Realtime realtime;
  late ably.RealtimeChannel channel;
  String? channelName;
  List<ably.Message> messages = [];

  List<StreamSubscription<dynamic>> _subscriptions = [];

  RealtimeService(this.ablyService, {Key? key})
      : realtime = ablyService.realtime;

  ably.RealtimeChannel setChannelByName(String name) {
    channelName = name;
    channel = realtime.channels.get(name);
    return channel;
  }

  void resetChannel() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions = [];
    messages = [];
  }

  void connect() {
    setupListeners();
    realtime.connect();
  }

  void publish(String message) async {
    if (channelState.value == ably.ChannelState.attached) {
      print(channel.name);
      try {
        channel.publish(
          message: ably.Message(
            data: message,
            timestamp: DateTime.now(),
          ),
        );
      } on ably.AblyException catch (e) {
        print(e);
      }
    }
  }

  void subscribe() async {
    final channelSubscription2 = channel.on().listen((stateChange) {
      channelState.value = channel.state;
    });
    _subscriptions.add(channelSubscription2);
    await channel.attach();

    if (channelState.value == ably.ChannelState.attached) {
      final subscription = channel.subscribe().listen((message) {
        latestMessage.value = message;
        messages.add(message);
        print(messages.length);
      });
      channelSubscription.value = subscription;
      _subscriptions.add(subscription);
      getHistory();
    }
  }

  void getHistory() {
    channel
        .history(ably.RealtimeHistoryParams(limit: 10, untilAttach: true))
        .then((value) {
      print('history: ${value.items.length}');
      messages.addAll(value.items);
    });
  }

  final ValueNotifier<ably.ConnectionState> connectionState =
      ValueNotifier<ably.ConnectionState>(ably.ConnectionState.initialized);
  final ValueNotifier<ably.ChannelState> channelState =
      ValueNotifier<ably.ChannelState>(ably.ChannelState.initialized);
  final ValueNotifier<ably.Message?> latestMessage =
      ValueNotifier<ably.Message?>(null);
  final ValueNotifier<StreamSubscription<ably.Message>?> channelSubscription =
      ValueNotifier<StreamSubscription<ably.Message>?>(null);

  void setupListeners() {
    dispose();
    final connectionSubscription =
        realtime.connection.on().listen((connectionStateChange) {
      if (connectionStateChange.current == ably.ConnectionState.failed) {
        print(connectionStateChange.reason);
      }
      connectionState.value = connectionStateChange.current;
    });
    //  _subscriptions.add(connectionSubscription);
  }
}
