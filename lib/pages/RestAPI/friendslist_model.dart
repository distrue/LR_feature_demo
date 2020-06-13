class FriendsListResponse {
  final data;

  const FriendsListResponse({
    this.data,
  });

  factory FriendsListResponse.fromJson(Map<String, dynamic> json) {
    return FriendsListResponse(
      data: FriendsListModel.fromJson(json['data']),
    );
  }
}

/*
class FriendsListModel {
  final int friendsNum;
  final List<FriendModel> friends;

  const FriendsListModel({
    this.friendsNum,
    this.friends,
  });

  factory FriendsListModel.fromJson(Map<String, dynamic> json) {
    var list = json['friends'] as List;
    List<FriendModel> friendsModelList =
        list.map((i) => FriendModel.fromJson(i)).toList();
    return FriendsListModel(
      friendsNum: json['friendsNum'],
      friends: friendsModelList,
    );
  }
}
*/

class FriendsListModel {
  final List<FriendModel> friends;

  const FriendsListModel({
    this.friends,
  });

  factory FriendsListModel.fromJson(List<dynamic> json) {
    List<FriendModel> friendsModelList =
        json.map((i) => FriendModel.fromJson(i)).toList();
    return FriendsListModel(friends: friendsModelList);
  }
}

/*
class FriendModel {
  final String name;
  final String message;
  final String music;
  final String musician;

  const FriendModel({
    this.name,
    this.message,
    this.music,
    this.musician,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      name: json['name'],
      message: json['message'],
      music: json['music'],
      musician: json['musician'],
    );
  }
}
*/

class FriendModel {
  final String id;
  final String key;

  const FriendModel({
    this.id,
    this.key,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'],
      key: json['key'],
    );
  }
}
