import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/ably_service.dart';
import '../services/realtime_service.dart';
import 'chat_details.dart';

class MainLayout extends StatefulWidget {
  final AblyService ablyService;

  const MainLayout({required this.ablyService, Key? key}) : super(key: key);
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentPage = 0;
  PageController pageController = PageController();
  late RealtimeService realtimeService;
  @override
  void initState() {
    realtimeService = RealtimeService(widget.ablyService);
    realtimeService.connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<ably.ConnectionState>(
              valueListenable: realtimeService.connectionState,
              builder: (_, ably.ConnectionState value, __) {
                String a = value.name;
                return Text(
                  'Status: $a',
                  style: TextStyle(
                    color: a == 'connected' ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
            Row(children: [item(0)]),
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (a) {
                  currentPage = a;
                  setState(() {});
                },
                children: [
                  ChatScreen(ablyService: realtimeService),
                  //   ChatScreen(ablyService: realtimeService),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget item(int i) {
    return Expanded(
      child: InkWell(
        onTap: () {
          pageController.animateToPage(
            i,
            duration: const Duration(seconds: 1),
            curve: Curves.linearToEaseOut,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          color: currentPage == i ? Colors.lightBlue : null,
          alignment: Alignment.center,
          child: Text(
            'Chats',
            style: TextStyle(
              fontSize: 18,
              color: currentPage == i ? Colors.white : null,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final RealtimeService ablyService;

  const ChatScreen({required this.ablyService, Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (_, i) {
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => ChatDetailsScreen(
                  ablyService: widget.ablyService,
                  name: users[i],
                ),
              ),
            );
          },
          leading: const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
          ),
          title: Text(
            users[i],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text(
            'Where are you?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  List<String> users = ['goodness', 'ella', 'oslo', 'richard', 'israel'];
}
