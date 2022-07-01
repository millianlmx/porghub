import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:porghub/components/chip.dart';
import 'package:porghub/data.dart';

class Chat extends StatefulWidget {
  const Chat({
    Key? key,
    required this.eventId,
    required this.group,
  }) : super(key: key);

  final String eventId;
  final bool group;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController controller = TextEditingController();
  List<Widget> messages = [
    const Bubble(
      isSend: true,
      message: "Ca va super et toi ?",
    ),
    const Bubble(
      isSend: false,
      message: "Salut, comment ça va ?",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("event")
            .doc(widget.eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.hasData) {
            Event event = Event.fromDocumentSnapshot(snapshot.data);
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Text(snapshot.data?["name"]),
                actions: [
                  widget.group
                      ? PopupMenuButton<String>(
                          onSelected: (choice) {},
                          itemBuilder: (BuildContext context) {
                            return {
                              'Ajouter un rôle',
                              'Supprimer un rôle',
                              'Exclure un membre'
                            }.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        )
                      : Container(),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    widget.group
                        ? Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: event.role.keys
                                  .map((String choice) {
                                    return RoleChip(
                                      role: choice,
                                      onTap: (state) {},
                                    );
                                  })
                                  .cast<Widget>()
                                  .toList(),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          (widget.group ? 0.8 : 0.85),
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection("event")
                              .doc(widget.eventId)
                              .collection("message")
                              .orderBy("createdAt")
                              .where("createdAt",
                                  isGreaterThanOrEqualTo: DateTime.now()
                                      .subtract(const Duration(days: 7)))
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.active &&
                                snapshot.hasData) {
                              return ListView(
                                reverse: true,
                                children: snapshot.data!.docs
                                    .map((queryDocumentSnapshot) => Bubble(
                                          message: queryDocumentSnapshot
                                              .data()["text"],
                                          isSend: queryDocumentSnapshot
                                                  .data()["author"] ==
                                              event.owner,
                                        ))
                                    .cast<Widget>()
                                    .toList(),
                              );
                            } else {
                              return const Scaffold(
                                body:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                          }),
                    ),
                    TextField(
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
                        suffixIcon: IconButton(
                          iconSize: 20.0,
                          onPressed: () => setState(() {
                            messages.insert(
                              0,
                              Bubble(
                                isSend: true,
                                message: controller.text,
                              ),
                            );
                            controller.clear();
                          }),
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
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}

class Bubble extends StatelessWidget {
  const Bubble({
    Key? key,
    required this.message,
    required this.isSend,
  }) : super(key: key);
  final String message;
  final bool isSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          child: Text(message),
        ),
      ),
    );
  }
}
