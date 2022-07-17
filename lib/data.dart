import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  info,
  text,
  audio,
  image,
}

MessageType stringToMessageType(String type) {
  if (type == 'info') {
    return MessageType.info;
  } else if (type == 'text') {
    return MessageType.text;
  } else if (type == 'audio') {
    return MessageType.audio;
  } else {
    return MessageType.image;
  }
}

class Message {
  const Message({
    required this.author,
    required this.createdAt,
    required this.text,
    required this.type,
  });

  final String author;
  final MessageType type;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'text': text,
        'author': author,
        'createdAt': Timestamp.fromDate(createdAt),
        'type': type.name,
      };

  Message.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>>? doc)
      : author = doc?.data()?["author"],
        type = stringToMessageType(doc?.data()?["type"]),
        text = doc?.data()?["text"],
        createdAt = DateTime.fromMillisecondsSinceEpoch(
            doc?.data()?["createdAt"].millisecondsSinceEpoch);
}

enum MemberLevel {
  starter,
  tuffer,
  organizer,
}

MemberLevel stringToMemberLevel(String level) {
  if (level == 'starter') {
    return MemberLevel.starter;
  } else if (level == 'tuffer') {
    return MemberLevel.tuffer;
  } else {
    return MemberLevel.organizer;
  }
}

class Member {
  const Member({
    required this.level,
    required this.name,
    required this.photo,
  });

  final MemberLevel level;
  final String name;
  final String photo;

  Map<String, dynamic> toMap() => {
        'level': level.name,
        'name': name,
        'photo': photo,
      };

  Member.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>>? doc)
      : name = doc?.data()?["name"],
        photo = doc?.data()?["photo"],
        level = stringToMemberLevel(doc?.data()?["level"]);
}

class Event {
  const Event({
    required this.name,
    required this.date,
    required this.owner,
    required this.place,
    required this.role,
  });

  final String name;
  final String place;
  final String date;
  final String owner;
  final Map<String, String> role;

  Map<String, dynamic> toMap() => {
        'name': name,
        'place': place,
        'date': date,
        'owner': owner,
        'role': role,
      };

  Event.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>>? doc)
      : name = doc?.data()?['name'],
        place = doc?.data()?['place'],
        date = doc?.data()?['date'],
        owner = doc?.data()?['owner'],
        role = doc?.data()?['role'].cast<String, String>();
}
