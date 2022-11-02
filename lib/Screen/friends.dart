import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import "package:flutter/material.dart";
import 'package:porghub/Screen/chat.dart';
import 'package:porghub/data.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({
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
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            return Center(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return FriendTile(
                    chatID: snapshot.data?.data()?["friends"][index],
                  );
                },
                itemCount: snapshot.data?.data()?["friends"].length,
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class FriendTile extends StatelessWidget {
  final String chatID;

  const FriendTile({
    Key? key,
    required this.chatID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          right: 10.0,
        ),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future:
                FirebaseFirestore.instance.collection("chat").doc(chatID).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data?.data()?["isRequestAccepted"]) {
                  return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection("chat")
                          .doc(chatID)
                          .collection("member")
                          .get(),
                      builder: (context, memberSnapshot) {
                        if (memberSnapshot.hasData &&
                            memberSnapshot.connectionState ==
                                ConnectionState.done) {
                          return FutureBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                              future: FirebaseFirestore.instance
                                  .collection("chat")
                                  .doc(chatID)
                                  .collection("message")
                                  .orderBy(
                                    "createdAt",
                                    descending: true,
                                  )
                                  .limit(1)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.connectionState ==
                                        ConnectionState.done) {
                                  Member friend = memberSnapshot
                                              .data?.docs[0].id ==
                                          FirebaseAuth.instance.currentUser?.uid
                                      ? Member.fromDocumentSnapshot(
                                          memberSnapshot.data?.docs[1],
                                        )
                                      : Member.fromDocumentSnapshot(
                                          memberSnapshot.data?.docs[0],
                                        );
                                  Message last = Message.fromDocumentSnapshot(
                                    snapshot.data?.docs[0],
                                  );
                                  return InkWell(
                                    onTap: () async {
                                      await FirebaseFirestore.instance
                                          .collection("chat")
                                          .doc(chatID)
                                          .collection("member")
                                          .doc(FirebaseAuth
                                              .instance.currentUser?.uid)
                                          .update({
                                        "token": await FirebaseMessaging
                                            .instance
                                            .getToken(
                                          vapidKey:
                                              "BMEBHFNT6NhEuSF9BMROWM6LPRBrkzP88GqxJ3m11R2SRO9XOevVFx6AzBs-Rdx2z1WfQQJl0kyKwuJAZa_QwBU",
                                        ),
                                      });
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => Chat(
                                            eventId: chatID,
                                            group: false,
                                            friendName: friend.name,
                                            friendId: memberSnapshot
                                                        .data?.docs[0].id ==
                                                    FirebaseAuth.instance
                                                        .currentUser?.uid
                                                ? memberSnapshot
                                                    .data?.docs[1].id
                                                : memberSnapshot
                                                    .data?.docs[0].id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 25.0,
                                                backgroundImage: NetworkImage(
                                                  friend.photo,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.025,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    friend.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: last.author ==
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser
                                                                      ?.uid
                                                              ? "Vous"
                                                              : friend.name,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText1
                                                                  ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                        ),
                                                        const TextSpan(
                                                          text: " ",
                                                        ),
                                                        TextSpan(
                                                          text: last.type ==
                                                                  MessageType
                                                                      .image
                                                              ? "image"
                                                              : last.text,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          thickness: 1.0,
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              });
                        } else {
                          return const CircularProgressIndicator();
                        }
                      });
                } else {
                  return const ListTile(
                    title: Text("Demande d'amis en cours d'acceptation"),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}

class FriendsAdder extends StatefulWidget {
  const FriendsAdder({Key? key}) : super(key: key);

  @override
  State<FriendsAdder> createState() => _FriendsAdderState();
}

class _FriendsAdderState extends State<FriendsAdder> {
  late TextEditingController email;

  @override
  void initState() {
    email = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Ajouter un ami"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            TextField(
              onSubmitted: (value) => setState(() => email.text = value),
              controller: email,
              decoration: InputDecoration(
                labelText: "Adresse email",
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                filled: true,
                suffixIcon: IconButton(
                  iconSize: 20.0,
                  onPressed: () async {
                    Query<Map<String, dynamic>> query = FirebaseFirestore
                        .instance
                        .collection("user")
                        .where("email", isEqualTo: email.text)
                        .limit(1);

                    QuerySnapshot<Map<String, dynamic>> snapshot =
                        await query.get();

                    DocumentReference documentReference =
                        FirebaseFirestore.instance.collection("chat").doc();

                    await documentReference.set({
                      "isRequestAccepted": false,
                      "member": {
                        FirebaseAuth.instance.currentUser?.uid:
                            snapshot.docs[0].id,
                        snapshot.docs[0].id:
                            FirebaseAuth.instance.currentUser?.uid,
                      },
                    });

                    DocumentSnapshot<Map<String, dynamic>> userData =
                        await FirebaseFirestore.instance
                            .collection("user")
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .get();

                    await FirebaseFirestore.instance
                        .collection("chat")
                        .doc(documentReference.id)
                        .collection("member")
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .set({
                      "level": userData.data()?["level"],
                      "name": userData.data()?["name"],
                      "photo": userData.data()?["photo"],
                    });

                    await FirebaseFirestore.instance
                        .collection("chat")
                        .doc(documentReference.id)
                        .collection("message")
                        .doc()
                        .set(
                          Message(
                            createdAt: DateTime.now(),
                            text: "Demande d'ami envoyée.",
                            author: FirebaseAuth.instance.currentUser!.uid,
                            type: MessageType.text,
                          ).toMap(),
                        );

                    await FirebaseFirestore.instance
                        .collection("request")
                        .doc(snapshot.docs[0].id)
                        .collection("ask")
                        .doc()
                        .set({
                      "chat": documentReference.id,
                      "member": {
                        FirebaseAuth.instance.currentUser?.uid:
                            snapshot.docs[0].id,
                        snapshot.docs[0].id:
                            FirebaseAuth.instance.currentUser?.uid,
                      },
                    });

                    List<dynamic> friends = userData.data()?["friends"];
                    friends.add(documentReference.id);

                    await FirebaseFirestore.instance
                        .collection("user")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      "friends": friends,
                    });

                    email.clear();
                  },
                  icon: const Icon(
                    Icons.send,
                    size: 20.0,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("request")
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection("ask")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.active) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection("chat")
                                .doc(snapshot.data?.docs[index].data()["chat"])
                                .collection("member")
                                .doc(snapshot.data?.docs[index]["member"]
                                    [FirebaseAuth.instance.currentUser?.uid])
                                .snapshots(),
                            builder: (context, friendSnapshot) {
                              if (friendSnapshot.hasData &&
                                  friendSnapshot.connectionState ==
                                      ConnectionState.active) {
                                return Text(
                                    "Demande d'ami de ${Member.fromDocumentSnapshot(friendSnapshot.data).name}");
                              } else {
                                return const Text("Chargement...");
                              }
                            },
                          ),
                          subtitle: Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final userData = await FirebaseFirestore
                                      .instance
                                      .collection("user")
                                      .doc(FirebaseAuth
                                          .instance.currentUser?.uid)
                                      .get();

                                  List<dynamic> friendList =
                                      userData.data()?["friends"];

                                  friendList.add(snapshot.data?.docs[index]
                                      .data()["chat"]);

                                  await FirebaseFirestore.instance
                                      .collection("user")
                                      .doc(FirebaseAuth
                                          .instance.currentUser?.uid)
                                      .update({"friends": friendList});

                                  await FirebaseFirestore.instance
                                      .collection("request")
                                      .doc(FirebaseAuth
                                          .instance.currentUser?.uid)
                                      .collection("ask")
                                      .doc(snapshot.data?.docs[index].id)
                                      .delete();

                                  await FirebaseFirestore.instance
                                      .collection("chat")
                                      .doc(snapshot.data?.docs[index]
                                          .data()["chat"])
                                      .update({"isRequestAccepted": true});

                                  await FirebaseFirestore.instance
                                      .collection("chat")
                                      .doc(snapshot.data?.docs[index]
                                          .data()["chat"])
                                      .collection("member")
                                      .doc(FirebaseAuth
                                          .instance.currentUser?.uid)
                                      .set(Member.fromDocumentSnapshot(userData)
                                          .toMap());
                                },
                                icon: const Icon(Icons.check),
                                label: const Text("Accepter"),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection("request")
                                      .doc(FirebaseAuth
                                          .instance.currentUser?.uid)
                                      .collection("ask")
                                      .doc(snapshot.data?.docs[index].id)
                                      .delete();
                                },
                                icon: const Icon(Icons.close),
                                label: const Text("Refuser"),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: snapshot.data?.size,
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
