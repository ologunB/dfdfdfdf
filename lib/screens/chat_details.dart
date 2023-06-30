import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import '../services/realtime_service.dart';

class ChatDetailsScreen extends StatefulWidget {
  final RealtimeService ablyService;

  final String name;
  const ChatDetailsScreen(
      {required this.ablyService, Key? key, required this.name})
      : super(key: key);

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  late RealtimeService realtimeService;
  @override
  void initState() {
    realtimeService = widget.ablyService;
    realtimeService.setChannelByName(conversationId(widget.name));
    realtimeService.subscribe();
  }

  @override
  void dispose() {
    realtimeService.resetChannel();
    super.dispose();
  }

  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FooterLayout(
          footer: Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      realtimeService.publish(controller.text);
                    },
                    icon: Icon(Icons.send),
                  )
                ],
              )),
          child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 20,
              itemBuilder: (_, i) {
                return Container(
                    margin: EdgeInsets.only(
                      bottom: 12,
                      right: i.isEven ? 100 : 0,
                      left: i.isOdd ? 100 : 0,
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i.isEven)
                          const Text(
                            'Daniel Tope',
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Text('blah blah $i'),
                      ],
                    ));
              }),
        ),
      ),
    );
  }

  String conversationId(String name) {
    return 'polyma';
    String myName = Platform.localeName;
    if (myName.hashCode > name.hashCode) {
      return 'persist:${myName}_$name';
    } else {
      return 'persist:${name}_$myName';
    }
  }
}
