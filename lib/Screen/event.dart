import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:porghub/Screen/chat.dart';

class Event extends StatelessWidget {
  const Event({
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
              child: ListView(
                padding: const EdgeInsets.all(10.0),
                children: snapshot.data
                    ?.data()?["events"]
                    .map<Widget>((eventID) => PartyCard(eventID: eventID))
                    .toList(),
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
  }) : super(key: key);

  final String eventID;

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
            return Card(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
                                        snapshotOwner.data?.data()?["photo"],
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
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Text(
                                "${snapshot.data?["place"]} ${snapshot.data?["date"]}",
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: "User ",
                          style:
                              Theme.of(context).textTheme.bodyText1?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        TextSpan(
                          text: "Last message",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              Text(
                                "25",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                              ),
                              Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (constext) => const Chat(
                                  title: "Test chat",
                                  group: true,
                                ),
                              ),
                            ),
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
        title: const Text("Nouveau événement"),
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
              await documentReference.set({
                "name": name.text,
                "place": place.text,
                "date": date.text,
                "owner": FirebaseAuth.instance.currentUser?.uid,
                "role": {},
              });

              final userData = await FirebaseFirestore.instance
                  .collection("user")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get();

              documentReference
                  .collection("member")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .set({
                "name": userData.data()?["name"],
                "photo": userData.data()?["photo"],
                "level": userData.data()?["level"],
              });

              documentReference.collection("message").doc().set({
                "text": "Événement créé !",
                "type": "info",
                "author": "${FirebaseAuth.instance.currentUser?.uid}",
              });

              List<dynamic> events = userData.data()?["events"];
              events.add(documentReference.id);

              FirebaseFirestore.instance
                  .collection("user")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .update({
                "events": events,
              });

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
