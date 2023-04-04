import 'dart:convert';

class Message {
  final String userName;
  final String userNumber;
  final String date;
  String messages;

  Message({
    this.messages = '',
    this.userNumber = '',
    this.userName = '',
    this.date = '',
  });

  static Map<String, dynamic> toJson(Message data) => {
        'userName': data.userName,
        'userNumber': data.userNumber,
        'date': data.date,
        'messages': data.messages,
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messages: json['messages'],
      userNumber: json['userNumber'],
      userName: json['userName'],
      date: json['date'],
    );
  }

  static String encode(List<Message> data) => json.encode(
        data.map<Map<String, dynamic>>((a) => Message.toJson(a)).toList(),
      );

  static List<Message> decode(String data) =>
      (json.decode(data) as List<dynamic>)
          .map<Message>((a) => Message.fromJson(a))
          .toList();
}
