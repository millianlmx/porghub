import 'package:flutter/material.dart';
import 'package:porghub/components/chip.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key, required this.title, required this.group})
      : super(key: key);

  final String title;
  final bool group;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController controller = TextEditingController();
  List<Widget> messages = [
    const SendBubble(
      message: "Ca va super et toi ?",
    ),
    const ReceiveBubble(
      message: "Salut, comment ça va ?",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Test Chat"),
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
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: {
                          'Mr Chips',
                          'Jeyffrey',
                          'Chauffeur',
                          'DJ'
                        }.map((String choice) {
                          return RoleChip(
                            role: choice,
                            onTap: (state){},
                          );
                        }).toList(),
                      ),
                    ),
                  )
                : Container(),
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  (widget.group ? 0.8 : 0.85),
              child: ListView(
                reverse: true,
                children: [
                  for (Widget message in messages) message,
                ],
              ),
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
                      SendBubble(message: controller.text),
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
  }
}

class SendBubble extends StatelessWidget {
  const SendBubble({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(7.5)),
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          child: Text(message),
        ),
      ),
    );
  }
}

class ReceiveBubble extends StatelessWidget {
  const ReceiveBubble({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(7.5)),
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
          child: Text(message),
        ),
      ),
    );
  }
}
