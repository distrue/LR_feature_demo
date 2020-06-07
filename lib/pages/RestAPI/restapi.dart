import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'friendslist_model.dart';

class RestApi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ActionBar(),
        Expanded(
          child: ListView(
            children: <Widget>[
              FriendsListItem(
                  name: '김성윤',
                  message: '상태 메세지 입니다',
                  music: '더 위로',
                  musician: '창모(CHANGMO)'),
              Container(
                height: 0.5,
                color: Colors.black12,
                margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 17),
              ),
              FriendsList(),
            ],
          ),
        )
      ],
    );
  }
}

class ActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(left: 17),
            child: Text('친구',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          )),
          _buildIcon(Icons.search),
          _buildIcon(Icons.person_add),
          _buildIcon(Icons.music_note),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: _buildIcon(Icons.settings),
          ),
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

class FriendsListItem extends StatelessWidget {
  const FriendsListItem({
    //this.photo,
    this.name,
    this.message,
    this.music,
    this.musician,
  });

  //final Widget photo;
  final String name;
  final String message;
  final String music;
  final String musician;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
            margin:
                const EdgeInsets.only(left: 17, right: 12, bottom: 8, top: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17.0),
              child: Image.asset(
                'images/anonymous.jpg',
                width: 43,
                height: 43,
                fit: BoxFit.contain,
              ),
            )),
        FriendInfo(
          name: name,
          message: message,
        ),
        MelonMusic(
          music: music,
          musician: musician,
        ),
      ],
    );
  }
}

class FriendInfo extends StatelessWidget {
  const FriendInfo({
    this.name,
    this.message,
  });

  final String name;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisSize: MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(name,
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.only(top: 2.5),
            child: Text(
              message,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.black38),
            ),
          ),
        ],
      ),
    );
  }
}

class MelonMusic extends StatelessWidget {
  const MelonMusic({
    this.music,
    this.musician,
  });

  final _melonColor = const Color(0xff00cd3c);
  final String music;
  final String musician;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: Container(
        padding:
            const EdgeInsets.only(top: 3.5, bottom: 3.5, left: 10, right: 5),
        decoration: BoxDecoration(
            border: Border.all(width: 1.1, color: _melonColor),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: <Widget>[
            Text(music + ' - ' + musician,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                )),
            Container(
                padding: EdgeInsets.only(bottom: 1.5),
                child: Icon(Icons.play_arrow, color: _melonColor, size: 14.5))
          ],
        ),
      ),
    );
  }
}

class FriendsList extends StatefulWidget {
  FriendsList({Key key}) : super(key: key);

  @override
  FriendsListState createState() => FriendsListState();
}

class FriendsListState extends State<FriendsList> {
  bool friendsOpen = true;
  Future<FriendsListResponse> futureFriendsListFromServer;

  @override
  void initState() {
    super.initState();
    futureFriendsListFromServer = fetchFriendsList();
  }

  void toggle() {
    setState(() {
      friendsOpen = !friendsOpen;
    });
  }

  getToggleFriendsList(List<FriendModel> friends) {
    if (friendsOpen) {
      return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          return FriendsListItem(
            name: friends[index].name,
            message: friends[index].message,
            music: friends[index].music,
            musician: friends[index].musician,
          );
        },
      );
    } else {
      return Container();
    }
  }

  getToggleFriendsListIcon() {
    IconData iconData;
    if (friendsOpen)
      iconData = Icons.keyboard_arrow_up;
    else
      iconData = Icons.keyboard_arrow_down;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Icon(
        iconData,
        size: 17,
        color: Colors.black54,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /*
    Why Scaffold Overflow?
    return Scaffold(
      body: Text('Seongyun Kim'),
    );
    return Container(
      child: Text('SeongYunKim'),
    );
    */
    return FutureBuilder<FriendsListResponse>(
      future: futureFriendsListFromServer,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 17, top: 7, bottom: 3),
                      child: Text(
                        '친구 ' + snapshot.data.data.friendsNum.toString(),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.black45),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: toggle,
                    child: getToggleFriendsListIcon(),
                  ),
                ],
              ),
              getToggleFriendsList(snapshot.data.data.friends),
            ],
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

Future<FriendsListResponse> fetchFriendsList() async {
  const String BASE_URL =
      'http://ec2-15-165-222-146.ap-northeast-2.compute.amazonaws.com:3000';
  final response = await http.get(BASE_URL + '/friends');
  if (response.statusCode == 200) {
    return FriendsListResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load FriendsList');
  }
}
