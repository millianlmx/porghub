import "package:flutter/material.dart";
import 'package:porghub/Screen/chat.dart';

class Event extends StatelessWidget {
  const Event({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        padding: const EdgeInsets.all(10.0),
        children: const <Widget>[
          PartyCard(),
          PartyCard(),
          PartyCard(),
          PartyCard(),
          PartyCard(),
          PartyCard(),
          PartyCard(),
          PartyCard(),
          PartyCard(),
          PartyCard(),
        ],
      ),
    );
  }
}

class PartyCard extends StatelessWidget {
  const PartyCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                Stack(
                  children: const [
                    CircleAvatar(// utilisateur qui organise
                      radius: 20.0,
                    ),
                    Positioned(
                      top: 25.0,
                      left: 25.0,
                      child: Text("⭐"), // niveau/grade
                    ),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.025,
                ),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nom evenement",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Text(
                        "Lieux Date",
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
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextSpan(
                  text: "Last message",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ]),
            ),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: "User ",
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
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
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
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
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
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
  }
}
