import 'package:flutter/material.dart';

class RestApi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ActionBar(),
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
        Expanded(
          child: FriendsList(),
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
      margin: EdgeInsets.only(right: 15),
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

  void toggle() {
    setState(() {
      friendsOpen = !friendsOpen;
    });
  }

  getToggleFriendsList() {
    if (friendsOpen) {
      //ListView를 Expanded로 감싸 Horizontal viewport was given unbounded height 에러 해결
      return Expanded(
        child: ListView(
          children: <FriendsListItem>[
            FriendsListItem(
                name: '정연길',
                message: '상태 메세지 입니다',
                music: 'Square(2017)',
                musician: '백예린'),
            FriendsListItem(
                name: '정의정',
                message: '상태 메세지 입니다',
                music: 'Homebody',
                musician: 'pH-1'),
            FriendsListItem(
                name: '강진범 멘토님',
                message: '상태 메세지 입니다',
                music: '폰서트',
                musician: '10CM'),
            FriendsListItem(
                name: '오우택 멘토님',
                message: '상태 메세지 입니다',
                music: '워커홀릭',
                musician: '볼빨간사춘기'),
            FriendsListItem(
                name: '이한솔 멘토님',
                message: '상태 메세지 입니다',
                music: '11:11',
                musician: '태연(TAEYEON)'),
            FriendsListItem(
                name: '주영민 멘토님',
                message: '상태 메세지 입니다',
                music: '마이동풍',
                musician: '배치기'),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  getToggleFriendsListIcon() {
    if (friendsOpen) {
      return Icon(
        Icons.keyboard_arrow_up,
        size: 17,
        color: Colors.black54,
      );
    } else {
      return Icon(
        Icons.keyboard_arrow_down,
        size: 17,
        color: Colors.black54,
      );
    }
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
    return Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 17, top: 7, bottom: 3),
                child: Text(
                  '친구 ' + '5',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.black45),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: toggle,
                child: getToggleFriendsListIcon(),
              ),
            )
          ],
        ),
        getToggleFriendsList(),
      ],
    );
  }
}

/*
Row(
  children: <Widget>[
    Container(
        margin: const EdgeInsets.only(left: 17, right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17.0),
          child: Image.asset(
            'images/anonymous.jpg',
            width: 43,
            height: 43,
            fit: BoxFit.contain,
          ),
        )),
    Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      //mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('김성윤',
            style:
                TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500)),
        Container(
            padding: const EdgeInsets.only(top: 2.5),
            child: Text(
              '상태 메세지 입니다.',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.black38),
            )),
      ],
    )),
    Container(
      margin: EdgeInsets.only(right: 15),
      child: Container(
          padding: const EdgeInsets.only(
              top: 3.5, bottom: 3.5, left: 10, right: 5),
          decoration: BoxDecoration(
              border: Border.all(width: 1.1, color: _melonColor),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: <Widget>[
              Text('Square(2017) - 백예린',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  )),
              Container(
                  padding: EdgeInsets.only(bottom: 1.5),
                  child: Icon(Icons.play_arrow,
                      color: _melonColor, size: 14.5))
            ],
          ),
      ),
    )
  ],
),
*/
