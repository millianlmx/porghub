import 'dart:typed_data';
import "package:http/http.dart" as http;
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:porghub/components/chip.dart';
import 'package:porghub/data.dart';

class Chat extends StatefulWidget {
  const Chat({
    Key? key,
    required this.eventId,
    required this.group,
    this.event,
    this.friendName,
    this.friendId,
  }) : super(key: key);

  final String eventId;
  final String? friendName;
  final String? friendId;
  final Event? event;
  final bool group;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.group ? widget.event!.name : widget.friendName!),
        actions: [
          widget.group
              ? Theme(
                  data: Theme.of(context).copyWith(
                    useMaterial3: false,
                  ),
                  child: PopupMenuButton<String>(
                    tooltip: "Options",
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    position: PopupMenuPosition.over,
                    onSelected: (choice) async {
                      if (choice == 'Changer de nom') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                NameChanger(eventID: widget.eventId),
                          ),
                        );
                      } else if (choice == "Partager l'évènement") {
                        bool copy =
                            await FlutterClipboard.controlC(widget.eventId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              copy
                                  ? "Code ajouter dans le presse-papier"
                                  : "Une erreur est survenue",
                            ),
                            action: SnackBarAction(
                              label: "OK",
                              onPressed: () => ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar(),
                            ),
                          ),
                        );
                      } else {
                        if (FirebaseAuth.instance.currentUser?.uid ==
                            widget.event!.owner) {
                          switch (choice) {
                            case 'Ajouter un rôle':
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RoleCreator(eventID: widget.eventId),
                                ),
                              );
                              break;
                            case 'Exclure un membre':
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MemberBanner(eventID: widget.eventId),
                                ),
                              );
                              break;
                            default:
                              break;
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  "Vous n'êtes pas l'organisateur de l'évènement !"),
                              action: SnackBarAction(
                                label: "OK",
                                onPressed: () => ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar(),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      Set<String> options =
                          FirebaseAuth.instance.currentUser?.uid ==
                                  widget.event!.owner
                              ? {
                                  'Changer de nom',
                                  "Partager l'évènement",
                                  'Ajouter un rôle',
                                  'Exclure un membre',
                                }
                              : {
                                  'Changer de nom',
                                  "Partager l'évènement",
                                };
                      return options.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                )
              : Container(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            widget.group
                ? StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection("event")
                        .doc(widget.eventId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active &&
                          snapshot.hasData) {
                        Event event = Event.fromDocumentSnapshot(snapshot.data);
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).devicePixelRatio >= 2.5
                              ? MediaQuery.of(context).size.height * 0.05 + 10
                              : MediaQuery.of(context).size.height * 0.1 + 10,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: snapshot.data
                                ?.data()?["role"]
                                .keys
                                .map((String choice) {
                                  return RoleChip(
                                    onLongPress: () async {
                                      if (FirebaseAuth
                                              .instance.currentUser!.uid ==
                                          widget.event!.owner) {
                                        await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'Suppression',
                                              ),
                                              content: Text(
                                                'Voulez-vous supprimer le rôle $choice ?',
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text(
                                                    'Non',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    event.role.remove(choice);
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("event")
                                                        .doc(widget.eventId)
                                                        .update({
                                                      "role": event.role
                                                    });
                                                    Navigator.pop(
                                                      context,
                                                    );
                                                  },
                                                  child: const Text('Oui'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              "Vous n'êtes pas l'organisateur de l'évènement !",
                                            ),
                                            action: SnackBarAction(
                                              label: "OK",
                                              onPressed: () =>
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar(),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    selected: event.role[choice] ==
                                        FirebaseAuth.instance.currentUser!.uid,
                                    role: choice,
                                    disabled: event.role[choice] != "" &&
                                        event.role[choice] !=
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                    onTap: (state) async {
                                      if (!state) {
                                        event.role[choice] = FirebaseAuth
                                            .instance.currentUser!.uid;
                                      } else {
                                        event.role[choice] = "";
                                      }
                                      await FirebaseFirestore.instance
                                          .collection("event")
                                          .doc(widget.eventId)
                                          .update({"role": event.role});
                                    },
                                  );
                                })
                                .cast<Widget>()
                                .toList(),
                          ),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    })
                : Container(),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection(widget.group ? "event" : "chat")
                      .doc(widget.eventId)
                      .collection("member")
                      .snapshots(),
                  builder: (context, roleSnapshot) {
                    if (roleSnapshot.hasData &&
                        roleSnapshot.connectionState ==
                            ConnectionState.active) {
                      Map<String, Member> members = {
                        for (var member in roleSnapshot.data!.docs)
                          member.id: Member.fromDocumentSnapshot(member)
                      };
                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection(widget.group ? "event" : "chat")
                              .doc(widget.eventId)
                              .collection("message")
                              .orderBy(
                                "createdAt",
                                descending: true,
                              )
                              .where(
                                "createdAt",
                                isGreaterThanOrEqualTo: DateTime.now()
                                    .subtract(const Duration(days: 10)),
                              )
                              .snapshots(),
                          builder: (context, msgSnapshot) {
                            if (msgSnapshot.connectionState ==
                                    ConnectionState.active &&
                                msgSnapshot.hasData) {
                              return ListView(
                                reverse: true,
                                children: msgSnapshot.data!.docs
                                    .map(
                                      (queryDocumentSnapshot) =>
                                          Message.fromDocumentSnapshot(
                                              queryDocumentSnapshot),
                                    )
                                    .cast<Message>()
                                    .map((message) {
                                      List<String> roles = widget.group
                                          ? widget.event!.role.entries
                                              .where(
                                                (entry) =>
                                                    entry.value ==
                                                    message.author,
                                              )
                                              .map<String>((entry) => entry.key)
                                              .toList()
                                              .cast<String>()
                                          : [];
                                      return Bubble(
                                        group: widget.group,
                                        message: message.text,
                                        type: message.type,
                                        author: members[message.author]!.name,
                                        role: roles.isEmpty
                                            ? ""
                                            : roles
                                                .map(
                                                  (role) =>
                                                      role.characters.first,
                                                )
                                                .toList()
                                                .join(),
                                        isSend: message.author ==
                                            FirebaseAuth
                                                .instance.currentUser?.uid,
                                      );
                                    })
                                    .cast<Widget>()
                                    .toList(),
                              );
                            } else {
                              return const Scaffold(
                                body:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                          });
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
            TextField(
              textInputAction: TextInputAction.send,
              onSubmitted: (value) async {
                if (value.replaceAll(RegExp(r" "), "").isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection(widget.group ? "event" : "chat")
                      .doc(widget.eventId)
                      .collection("message")
                      .doc()
                      .set(
                        Message(
                          author: FirebaseAuth.instance.currentUser!.uid,
                          createdAt: DateTime.now(),
                          text: value,
                          type: MessageType.text,
                        ).toMap(),
                      );
                  DocumentSnapshot<Map<String, dynamic>> doc =
                      await FirebaseFirestore.instance
                          .collection(widget.group ? "event" : "chat")
                          .doc(widget.eventId)
                          .collection("member")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();

                  Member me = Member.fromDocumentSnapshot(doc);

                  DocumentSnapshot<Map<String, dynamic>> friendDoc =
                      await FirebaseFirestore.instance
                          .collection(widget.group ? "event" : "chat")
                          .doc(widget.eventId)
                          .collection("member")
                          .doc(widget.friendId)
                          .get();
                  controller.clear();
                  http.Response response;
                  widget.group
                      ? response = await http.get(
                          Uri.parse(
                            "https://us-central1-porghub-8da18.cloudfunctions.net/notifyGroup?groupId=${widget.eventId}&groupName=${widget.event?.name}&userName=${me.name}&message=$value",
                          ),
                        )
                      : response = await http.get(
                          Uri.parse(
                            "us-central1-porghub-8da18.cloudfunctions.net/notifyUser?token=${friendDoc["token"]}&userId=${widget.friendId!}&userName=${me.name}&message=$value",
                          ),
                        );
                }
              },
              controller: controller,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  ?.copyWith(fontSize: 18.0),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.only(
                  top: 5.0,
                  bottom: 5.0,
                  left: 10.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                prefixIcon: IconButton(
                  onPressed: () async {
                    XFile? image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    Uint8List? bytes = await image?.readAsBytes();

                    Image.memory(bytes!);

                    TaskSnapshot snapshot = await FirebaseStorage.instance
                        .ref()
                        .child(
                            "${image!.path.split("/").last}.${image.name.split(".").last}")
                        .putData(bytes);

                    String url = await snapshot.ref.getDownloadURL();

                    await FirebaseFirestore.instance
                        .collection(widget.group ? "event" : "chat")
                        .doc(widget.eventId)
                        .collection("message")
                        .doc()
                        .set(Message(
                          author: FirebaseAuth.instance.currentUser!.uid,
                          createdAt: DateTime.now(),
                          text: url,
                          type: MessageType.image,
                        ).toMap());
                  },
                  icon: const Icon(Icons.image),
                ),
                suffixIcon: IconButton(
                  iconSize: 20.0,
                  onPressed: () async {
                    if (controller.text
                        .replaceAll(RegExp(r" "), "")
                        .isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection(widget.group ? "event" : "chat")
                          .doc(widget.eventId)
                          .collection("message")
                          .doc()
                          .set(
                            Message(
                              author: FirebaseAuth.instance.currentUser!.uid,
                              createdAt: DateTime.now(),
                              text: controller.text,
                              type: MessageType.text,
                            ).toMap(),
                          );
                      DocumentSnapshot<Map<String, dynamic>> doc =
                          await FirebaseFirestore.instance
                              .collection(widget.group ? "event" : "chat")
                              .doc(widget.eventId)
                              .collection("member")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .get();

                      Member me = Member.fromDocumentSnapshot(doc);

                      DocumentSnapshot<Map<String, dynamic>> friendDoc =
                          await FirebaseFirestore.instance
                              .collection(widget.group ? "event" : "chat")
                              .doc(widget.eventId)
                              .collection("member")
                              .doc(widget.friendId)
                              .get();
                      controller.clear();
                      http.Response response;
                      widget.group
                          ? response = await http.get(
                              Uri.parse(
                                "https://us-central1-porghub-8da18.cloudfunctions.net/notifyGroup?groupId=${widget.eventId}&groupName=${widget.event?.name}&userName=${me.name}&message=${controller.text}",
                              ),
                            )
                          : response = await http.get(
                              Uri.parse(
                                "https://us-central1-porghub-8da18.cloudfunctions.net/notifyUser?token=${friendDoc["token"]}&userId=${widget.friendId!}&userName=${me.name}&message=${controller.text}",
                              ),
                            );
                    }
                  },
                  icon: const Icon(
                    Icons.send,
                    size: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  const Bubble({
    Key? key,
    required this.message,
    required this.isSend,
    required this.author,
    required this.role,
    required this.type,
    required this.group,
  }) : super(key: key);
  final bool group;
  final String message;
  final MessageType type;
  final String author;
  final String role;
  final bool isSend;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        group
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Align(
                  alignment:
                      isSend ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text("$author $role"),
                ),
              )
            : const SizedBox(),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Align(
            alignment: isSend ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(7.5)),
                color: isSend
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.tertiaryContainer,
              ),
              child: type == MessageType.text
                  ? SelectableText(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    )
                  : Image.network(
                      message,
                      height: MediaQuery.of(context).size.height * 0.3,
                      fit: BoxFit.fitHeight,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class RoleCreator extends StatefulWidget {
  const RoleCreator({
    Key? key,
    required this.eventID,
  }) : super(key: key);
  final String eventID;

  @override
  State<RoleCreator> createState() => RoleCreatorState();
}

class RoleCreatorState extends State<RoleCreator> {
  late TextEditingController name;
  late TextEditingController emoji;

  @override
  void initState() {
    name = TextEditingController();
    emoji = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Nouveau rôle"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Ajouter'),
            onPressed: () async {
              final event = await FirebaseFirestore.instance
                  .collection("event")
                  .doc(widget.eventID)
                  .get();
              final roles = event.data()?["role"];
              roles["${emoji.text} ${name.text}"] = "";

              await FirebaseFirestore.instance
                  .collection("event")
                  .doc(widget.eventID)
                  .update({"role": roles});

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
              onChanged: (value) => setState(() => emoji.text = value),
              controller: emoji,
              maxLength: 1,
              decoration: InputDecoration(
                labelText: "Emoji du rôle",
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                filled: true,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            TextField(
              textInputAction: TextInputAction.done,
              onSubmitted: (value) async {
                final event = await FirebaseFirestore.instance
                    .collection("event")
                    .doc(widget.eventID)
                    .get();
                final roles = event.data()?["role"];
                roles["${emoji.text} $value"] = "";

                await FirebaseFirestore.instance
                    .collection("event")
                    .doc(widget.eventID)
                    .update({"role": roles});

                Navigator.of(context).pop();
              },
              onEditingComplete: () => setState(() => name.text),
              controller: name,
              decoration: InputDecoration(
                labelText: "Nom du rôle",
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

class NameChanger extends StatefulWidget {
  const NameChanger({
    Key? key,
    required this.eventID,
  }) : super(key: key);
  final String eventID;

  @override
  State<NameChanger> createState() => NameChangerState();
}

class NameChangerState extends State<NameChanger> {
  late TextEditingController name;

  @override
  void initState() {
    name = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Nouveau nom"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Changer'),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("event")
                  .doc(widget.eventID)
                  .collection("member")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                "name": name.text,
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
              onSubmitted: (value) async {
                await FirebaseFirestore.instance
                    .collection("event")
                    .doc(widget.eventID)
                    .collection("member")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                  "name": value,
                });

                Navigator.of(context).pop();
              },
              onEditingComplete: () => setState(() => name.text),
              controller: name,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: "Nouveau nom",
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

class MemberBanner extends StatefulWidget {
  const MemberBanner({
    Key? key,
    required this.eventID,
  }) : super(key: key);
  final String eventID;

  @override
  State<MemberBanner> createState() => _MemberBannerState();
}

class _MemberBannerState extends State<MemberBanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Exclure un membre"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("event")
            .doc(widget.eventID)
            .collection("member")
            .snapshots(),
        builder: (context, snapshot) => snapshot.hasData &&
                snapshot.connectionState == ConnectionState.active
            ? ListView.builder(
                itemCount: snapshot.data?.size,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        Member.fromDocumentSnapshot(snapshot.data?.docs[index])
                            .photo),
                  ),
                  title: Text(
                    Member.fromDocumentSnapshot(snapshot.data?.docs[index])
                        .name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 20.0,
                        ),
                    textAlign: TextAlign.left,
                  ),
                  onTap: () async {
                    Member member =
                        Member.fromDocumentSnapshot(snapshot.data?.docs[index]);

                    await FirebaseFirestore.instance
                        .collection("event")
                        .doc(widget.eventID)
                        .collection("banned")
                        .doc(snapshot.data?.docs[index].id)
                        .set(member.toMap());

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${member.name} a été exlue !",
                        ),
                        action: SnackBarAction(
                          label: "OK",
                          onPressed: () => ScaffoldMessenger.of(context)
                              .hideCurrentSnackBar(),
                        ),
                      ),
                    );
                  },
                ),
              )
            : const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }
}
