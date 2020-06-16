import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hello/pages/SocketIO/recentchat_info.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:provider/provider.dart';
import 'package:hello/login_info.dart';
import 'dart:convert';
import 'package:lottie/lottie.dart';

const _kakaoBackgroundColor = Color(0xffaec3d2);
const _kakaoColor = Color(0xfff8de00);
final boxDecoration = BoxDecoration(
  color: _kakaoBackgroundColor,
  border: Border.all(width: 0, color: _kakaoBackgroundColor),
);

class SocketIO extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ActionBar(),
        Expanded(
          child: MessageList(),
        )
      ],
    );
  }
}

class ActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration,
      padding: const EdgeInsets.all(7),
      child: Row(
        children: <Widget>[
          _buildIcon(Icons.arrow_back),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 7),
              child: Text('그룹채팅',
                  style:
                      TextStyle(fontSize: 18.5, fontWeight: FontWeight.w600)),
            ),
          ),
          _buildIcon(Icons.search),
          _buildIcon(Icons.menu),
        ],
      ),
    );
  }

  Container _buildIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(9),
      child: Icon(icon, size: 25),
    );
  }
}

class MessageList extends StatefulWidget {
  MessageList({Key key}) : super(key: key);

  @override
  MessageListState createState() => MessageListState();
}

class MessageListState extends State<MessageList>
    with AutomaticKeepAliveClientMixin<MessageList> {
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textEditingController = new TextEditingController();
  bool isTextFieldEmpty = true;
  WebSocketChannel channel;
  Future<List<dynamic>> futureRecentChatList;

  @override
  void initState() {
    super.initState();
    futureRecentChatList = fetchRecentChatList();
    channel = IOWebSocketChannel.connect('ws://15.164.167.20:4000/', headers: {
      'token': Provider.of<LoginInfo>(context, listen: false).token
    });
    _textEditingController.addListener(textFieldOnChange);
    channel.stream.listen((data) {
      debugPrint("11111/DataReceived: " + data);
      Provider.of<RecentChatInfo>(context, listen: false)
          .addRecentChat(json.decode(data));
    }, onDone: () {
      debugPrint("11111/Task Done");
    }, onError: (error) {
      debugPrint("11111/Some Error");
    });
  }

  void textFieldOnChange() {
    if (_textEditingController.text.length == 0 && !isTextFieldEmpty) {
      setState(() {
        isTextFieldEmpty = true;
      });
    } else if (_textEditingController.text.length != 0 && isTextFieldEmpty) {
      setState(() {
        isTextFieldEmpty = false;
      });
    }
  }

  void _sendMessage(String text) {
    channel.sink.add(json.encode({
      'msg': text,
      'from': Provider.of<LoginInfo>(context, listen: false).name
    }));
    _textEditingController.clear();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) =>
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            color: _kakaoBackgroundColor,
            child: FutureBuilder<List<dynamic>>(
              future: futureRecentChatList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  bool isComplete =
                      Provider.of<RecentChatInfo>(context, listen: false)
                          .isComplete;
                  if (!isComplete) {
                    Provider.of<RecentChatInfo>(context, listen: false)
                        .setRecentChatList(snapshot.data);
                  }
                  return Consumer<RecentChatInfo>(
                    builder: (context, recentChatInfo, child) {
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: recentChatInfo.recentChatList.length,
                        controller: _scrollController,
                        itemBuilder: (BuildContext context, int index) {
                          return ChatMessageItem(
                              text: recentChatInfo.recentChatList[index]['msg'],
                              userName: recentChatInfo.recentChatList[index]
                                  ['from'],
                              isMyMessage: recentChatInfo.recentChatList[index]
                                      ['from'] ==
                                  Provider.of<LoginInfo>(context, listen: false)
                                      .name);
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Container(
                  color: _kakaoBackgroundColor,
                  child: Center(
                    child: Lottie.asset(
                        //'assets/24504-dots-loading-animation.json',
                        'assets/24186-pride-colors-circle-loading.json',
                        width: 150,
                        height: 150,
                        fit: BoxFit.fill),
                  ),
                );
              },
            ),
          ),
        ),
        Row(
          children: <Widget>[
            _buildIcon(Icons.add_circle_outline),
            Expanded(
              child: TextField(
                cursorColor: Color(0xff2e5984),
                cursorWidth: 1,
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            _buildIcon(Icons.tag_faces),
            getSendIcon(),
          ],
        )
      ],
    );
  }

  Widget getSendIcon() {
    if (isTextFieldEmpty) {
      return _buildIcon(Icons.keyboard_voice);
    } else {
      return GestureDetector(
        onTap: () => _sendMessage(_textEditingController.text),
        child: Container(
          color: _kakaoColor,
          child: Container(
            padding: const EdgeInsets.all(11),
            child: Icon(
              Icons.send,
              size: 28,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
  }

  Container _buildIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(11),
      child: Icon(
        icon,
        size: 28,
        color: Colors.black26,
      ),
    );
  }

  Future<List<dynamic>> fetchRecentChatList() async {
    const String BASE_URL = 'http://15.164.167.20:5000';
    Map<String, String> requestsHeaders = {
      'X-Access-Token': Provider.of<LoginInfo>(context, listen: false).token
    };
    final response =
        await http.get(BASE_URL + '/recent', headers: requestsHeaders);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load RecentChatList');
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class ChatMessageItem extends StatelessWidget {
  ChatMessageItem({this.text, this.userName, this.isMyMessage});

  final String text;
  final String userName;
  final bool isMyMessage;

  @override
  Widget build(BuildContext context) {
    if (isMyMessage) {
      return Container(
        decoration: boxDecoration,
        padding: EdgeInsets.only(right: 10, top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MessageBubble(isMyMessage: true, text: text),
          ],
        ),
      );
    } else {
      return Container(
        decoration: boxDecoration,
        padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'images/anonymous.jpg',
                  width: 39,
                  height: 39,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //TODO 보낸 사람 이름
                Container(
                  padding: EdgeInsets.only(top: 3, bottom: 6),
                  child: Text(
                    userName,
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400),
                  ),
                ),
                MessageBubble(isMyMessage: false, text: text),
              ],
            )
          ],
        ),
      );
    }
  }
}

class MessageBubble extends StatefulWidget {
  MessageBubble({Key key, this.isMyMessage, this.text}) : super(key: key);

  final isMyMessage;
  final text;

  @override
  MessageBubbleState createState() => MessageBubbleState();
}

class MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    if (widget.isMyMessage)
      color = _kakaoColor;
    else
      color = Color(0xffffffff);
    return FadeTransition(
      opacity: animation,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 8, right: 11, left: 11),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
