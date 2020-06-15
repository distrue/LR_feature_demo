import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:provider/provider.dart';
import 'package:hello/login_info.dart';
import 'dart:convert';

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

class MessageListState extends State<MessageList> {
  List<Map<String, dynamic>> messages = List<Map<String, dynamic>>();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textEditingController = new TextEditingController();
  bool isTextFieldEmpty = true;
  WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    fetchRecentChatList().then((value) {
      debugPrint("HelloHello");
      value.forEach((element) => messages.add(element));
      setState(() {});
    });
    channel = IOWebSocketChannel.connect('ws://15.164.167.20:4000/', headers: {
      'token': Provider.of<LoginInfo>(context, listen: false).token
    });
    _textEditingController.addListener(textFieldOnChange);
    channel.stream.listen((data) {
      debugPrint("11111/DataReceived: " + data);
      setState(() {
        messages.add(json.decode(data));
      });
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            color: _kakaoBackgroundColor,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: messages.length,
              controller: _scrollController,
              itemBuilder: (BuildContext context, int index) {
                return ChatMessageItem(
                    text: messages[index]['msg'],
                    userName: messages[index]['from'],
                    isMyMessage: messages[index]['from'] ==
                        Provider.of<LoginInfo>(context, listen: false).name);
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
            getMessageBubble(context, isMyMessage),
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
                getMessageBubble(context, isMyMessage),
              ],
            )
          ],
        ),
      );
    }
  }

  Container getMessageBubble(BuildContext context, bool isMyMessage) {
    Color color;
    if (isMyMessage)
      color = _kakaoColor;
    else
      color = Color(0xffffffff);
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 11, left: 11),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
