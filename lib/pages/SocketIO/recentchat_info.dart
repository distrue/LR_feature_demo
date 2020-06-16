import 'package:flutter/cupertino.dart';

class RecentChatInfo extends ChangeNotifier{
  bool isComplete = false;
  List<dynamic> recentChatList;

  void setRecentChatList(List<dynamic> recentChatList) {
    this.recentChatList = recentChatList;
    isComplete = true;
    notifyListeners();
  }

  void addRecentChat(Map<String, dynamic> recentChat){
    this.recentChatList.add(recentChat);
    notifyListeners();
  }

  void deleteRecentChatList() {
    this.recentChatList.clear();
    isComplete = false;
  }
}
