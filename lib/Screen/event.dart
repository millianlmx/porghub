import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import "package:flutter/material.dart";
import 'package:porghub/Screen/chat.dart';
import 'package:porghub/data.dart';
import "package:http/http.dart" as http;

class EventPage extends StatelessWidget {
  const EventPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("user")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.hasData) {
            return Center(
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemBuilder: (context, index) => PartyCard(
                  eventID: snapshot.data?.data()?["event"][index],
                  userData: snapshot.data!.data()!,
                ),
                itemCount: snapshot.data?.data()?["event"].length,
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class PartyCard extends StatelessWidget {
  const PartyCard({
    Key? key,
    required this.eventID,
    required this.userData,
  }) : super(key: key);

  final String eventID;
  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("event")
            .doc(eventID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.hasData) {
            Event event = Event.fromDocumentSnapshot(snapshot.data);
            return Card(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Suppression',
                        ),
                        content: Text(
                          'Voulez-vous supprimer l\'évènement ${snapshot.data?.data()?["name"]} ?',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Non',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              List<dynamic> event = userData["event"];
                              event.remove(eventID);

                              await FirebaseFirestore.instance
                                  .collection("user")
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .update({"event": event});

                              Navigator.pop(
                                context,
                              );
                            },
                            child: const Text('Oui'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            StreamBuilder<
                                    DocumentSnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection("event")
                                    .doc(eventID)
                                    .collection("member")
                                    .doc(snapshot.data?.data()?["owner"])
                                    .snapshots(),
                                builder: (context, snapshotOwner) {
                                  if (snapshotOwner.connectionState ==
                                          ConnectionState.active &&
                                      snapshotOwner.hasData) {
                                    return Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            snapshotOwner.data
                                                ?.data()?["photo"],
                                          ),
                                          radius: 20.0,
                                        ),
                                        const Positioned(
                                          top: 25.0,
                                          left: 25.0,
                                          child: Text("⭐"), // niveau/grade
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                }),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.025,
                            ),
                            SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data?["name"],
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  Text(
                                    "${snapshot.data?["place"]} ${snapshot.data?["date"]}",
                                    style:
                                        Theme.of(context).textTheme.subtitle2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            future: FirebaseFirestore.instance
                                .collection("event")
                                .doc(eventID)
                                .collection("message")
                                .orderBy(
                                  "createdAt",
                                  descending: true,
                                )
                                .limit(1)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                                Message message = Message.fromDocumentSnapshot(
                                  snapshot.data?.docs.first,
                                );
                                return FutureBuilder<
                                        DocumentSnapshot<Map<String, dynamic>>>(
                                    future: FirebaseFirestore.instance
                                        .collection("event")
                                        .doc(eventID)
                                        .collection("member")
                                        .doc(message.author)
                                        .get(),
                                    builder: (context, snapshotUser) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: snapshotUser.data
                                                    ?.data()?["name"],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const TextSpan(
                                                text: " ",
                                              ),
                                              TextSpan(
                                                text: message.type ==
                                                        MessageType.image
                                                    ? "image"
                                                    : message.text,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    });
                              } else {
                                return Container();
                              }
                            }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Row(
                                children: [
                                  FutureBuilder<
                                          QuerySnapshot<Map<String, dynamic>>>(
                                      future: FirebaseFirestore.instance
                                          .collection("event")
                                          .doc(eventID)
                                          .collection("member")
                                          .get(),
                                      builder: (context, snapshotLength) {
                                        if (snapshotLength.connectionState ==
                                                ConnectionState.done &&
                                            snapshotLength.hasData) {
                                          return Text(
                                            snapshotLength.data!.size
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                ),
                                          );
                                        } else {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                      }),
                                  Icon(
                                    Icons.person,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Theme.of(context)
                                              .colorScheme
                                              .primaryContainer),
                                ),
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (constext) => Chat(
                                        event: event,
                                        eventId: eventID,
                                        group: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Discuter",
                                  style: Theme.of(context).textTheme.button,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class EventCreator extends StatefulWidget {
  const EventCreator({Key? key}) : super(key: key);

  @override
  State<EventCreator> createState() => EventCreatorState();
}

class EventCreatorState extends State<EventCreator> {
  late TextEditingController name;
  late TextEditingController date;
  late TextEditingController place;

  @override
  void initState() {
    name = TextEditingController();
    date = TextEditingController();
    place = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Nouvel événement"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Enregister'),
            onPressed: () async {
              final documentReference =
                  FirebaseFirestore.instance.collection("event").doc();
              await documentReference.set(Event(
                name: name.text,
                place: place.text,
                date: date.text,
                owner: FirebaseAuth.instance.currentUser!.uid,
                role: {},
              ).toMap());

              final userData = await FirebaseFirestore.instance
                  .collection("user")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get();

              await documentReference
                  .collection("member")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .set(Member(
                    name: userData.data()?["name"],
                    photo: userData.data()?["photo"],
                    level: stringToMemberLevel(userData.data()?["level"]),
                  ).toMap());

              await documentReference.collection("message").doc().set(Message(
                    text: "Événement créé !",
                    type: MessageType.text,
                    author: "${FirebaseAuth.instance.currentUser?.uid}",
                    createdAt: DateTime.now(),
                  ).toMap());

              List<String> events = userData.data()?["event"].cast<String>();
              events.add(documentReference.id);

              await FirebaseFirestore.instance
                  .collection("user")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .update({
                "event": events,
              });

              String? token = await FirebaseMessaging.instance.getToken(
                vapidKey:
                    "BMEBHFNT6NhEuSF9BMROWM6LPRBrkzP88GqxJ3m11R2SRO9XOevVFx6AzBs-Rdx2z1WfQQJl0kyKwuJAZa_QwBU",
              );
              http.Response response = await http.get(Uri.dataFromString(
                  "https://us-central1-porghub-8da18.cloudfunctions.net/subscribeToTopic?token=$token&userId=${FirebaseAuth.instance.currentUser?.uid}&topic=${documentReference.id}"));

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            TextField(
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => setState(() => name.text = value),
              controller: name,
              decoration: InputDecoration(
                labelText: "Nom de l'évènement",
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                filled: true,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            TextField(
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => setState(() => date.text = value),
              controller: date,
              decoration: InputDecoration(
                labelText: "Date de l'évènement",
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                filled: true,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            TextField(
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => setState(() => place.text = value),
              controller: place,
              decoration: InputDecoration(
                labelText: "Lieu de l'évènement",
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                filled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventJoiner extends StatefulWidget {
  const EventJoiner({Key? key}) : super(key: key);

  @override
  State<EventJoiner> createState() => EventJoinerState();
}

class EventJoinerState extends State<EventJoiner> {
  late TextEditingController code;

  @override
  void initState() {
    code = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Rejoindre un événement"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Rejoindre'),
            onPressed: () async {
              final userData = await FirebaseFirestore.instance
                  .collection("user")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get();

              List<String> events = userData.data()?["event"].cast<String>();
              events.add(code.text);

              await FirebaseFirestore.instance
                  .collection("event")
                  .doc(code.text)
                  .collection("member")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .set(Member(
                    name: userData["name"],
                    photo: userData["photo"],
                    level: stringToMemberLevel(userData["level"]),
                  ).toMap());

              await FirebaseFirestore.instance
                  .collection("user")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .update({
                "event": events,
              });

              String? token = await FirebaseMessaging.instance.getToken(
                vapidKey:
                    "BMEBHFNT6NhEuSF9BMROWM6LPRBrkzP88GqxJ3m11R2SRO9XOevVFx6AzBs-Rdx2z1WfQQJl0kyKwuJAZa_QwBU",
              );
              http.Response response = await http.get(Uri.dataFromString(
                  "https://us-central1-porghub-8da18.cloudfunctions.net/subscribeToTopic?token=$token&userId=${FirebaseAuth.instance.currentUser?.uid}&topic=${code.text}"));

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            TextField(
              textInputAction: TextInputAction.done,
              onSubmitted: (value) async {
                final userData = await FirebaseFirestore.instance
                    .collection("user")
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .get();

                List<String> events = userData.data()?["event"].cast<String>();
                events.add(value);

                await FirebaseFirestore.instance
                    .collection("event")
                    .doc(value)
                    .collection("member")
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .set(Member(
                      name: userData["name"],
                      photo: userData["photo"],
                      level: stringToMemberLevel(userData["level"]),
                    ).toMap());

                await FirebaseFirestore.instance
                    .collection("user")
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .update({
                  "event": events,
                });

                Navigator.of(context).pop();
              },
              controller: code,
              decoration: InputDecoration(
                labelText: "Code de l'évènement",
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                filled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
