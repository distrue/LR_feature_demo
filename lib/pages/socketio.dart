import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String _name = "User132";


/*class SocketIO extends StatelessWidget {
    Widget build(BuildContext context){
        return Card(color: Colors.green);
    }
}*/


class SocketIO extends StatefulWidget {
  final WebSocketChannel channel = IOWebSocketChannel.connect('ws://15.164.167.20:4000/');

  SocketIO({Key key}): super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SocketIO> {
  TextEditingController _controller = TextEditingController();

  final TextEditingController _textController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: widget.channel.stream,
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(snapshot.hasData ? '${snapshot.data}': '')
              );
            }
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor
            ),
            child: _buildTextComposer(),
          )
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    widget.channel.sink.add(text);
  }

  @override void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
  Widget _buildTextComposer() { 
    return IconTheme( 
      data: IconThemeData(
        color: Theme.of(context).accentColor
      ), 
      child: Container( 
        margin: const EdgeInsets.symmetric(horizontal: 8.0), 
        child: Row( 
          children: <Widget>[ 
            Flexible( 
              child: TextField( 
                controller: _textController, 
                onSubmitted: _sendMessage, 
                decoration: new InputDecoration.collapsed( hintText: "Send a message"),
              ),
            ), 
            Container( 
              margin: const EdgeInsets.symmetric(horizontal: 4.0), 
              child: IconButton( 
                icon: Icon(Icons.send), 
                onPressed: () => _sendMessage(_textController.text)
              ),
            ), 
          ], 
        ) 
      ),
    ); 
  } 
}

class ChatMessage extends StatelessWidget { 
  ChatMessage({this.text}); 
  final String text; 
  @override Widget build(BuildContext context) { 
    return Container( 
      margin: const EdgeInsets.symmetric(vertical: 10.0), 
      child: Row( 
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: <Widget>[ 
          Container( 
            margin: const EdgeInsets.only(right: 16.0), 
            child: CircleAvatar(child: Text(_name[0])),
          ), 
          Column( 
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: <Widget>[ 
              Text(_name),
              Container( margin: const EdgeInsets.only(top: 5.0), child: Text(text), ),
            ], 
          ),
        ], 
      ), 
    ); 
  } 
}
