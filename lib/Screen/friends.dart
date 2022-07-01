import "package:flutter/material.dart";
import 'package:porghub/Screen/chat.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        padding: const EdgeInsets.all(10.0),
        children: const <Widget>[
          FriendTile(),
          FriendTile(),
          FriendTile(),
          FriendTile(),
          FriendTile(),
          FriendTile(),
          FriendTile(),
          FriendTile(),
          FriendTile(),
        ],
      ),
    );
  }
}

class FriendTile extends StatelessWidget {
  const FriendTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const Chat(
              eventId: "Premier amis",
              group: false,
            ),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30.0,
                    backgroundImage: NetworkImage(
                      "https://lh3.googleusercontent.com/Zzkf9SPKY8TFp4xavyriaK4mAIXWU4fpRSKENWsk7PI9QXGxKApey1U9Lk8lQMxnspkTN28UMCOigswI5Rqn4k5suyQnXYjBSj_hXn3aEllK2_msi45UtPZaZQDG4HVnoYbLtkHOVW38DS5vSZ6wAKVnm1fAeLa7-hoRLQI0KyyiG5YdgGmLZtKsLeusClJsXImmIo0MBzVnEekLjVvWE6j066ZNa6VOQmtOb1svmPy0vCeL_0-cMUBWkJhk17llzK58Ko5z5hJb-eKyvgVJSDindMOo5RMuQpfTbI7zLZ9xWrLvgfOSb1YrEoxObCTZXiwl3Ok60XHg8HLjLFC6TZ_FiUwQ22vmqJwoEYirckyfuhtUst56b1ApJweTsJryWOK0LCM-a4e5s9iR7QuuqygZat6egTugZQE2RutDi_JGriI6N9Up58qwkqUAqrQFSYoEGQW2oNrlWbVQMYeCRubpng5vTiHcPhSvcaE9Dc_ZrVk5-SggR6suwdGuT39usZijCsjUG_Q8Uqu7frj-ptLpejE3S4zPwvYRGOOnYqj8AWcRCdl76q1hU731Rmro1dhilZzPRAlotv2udXmO6CvOVMzVVVeQC8ywgUq40JJOCEkZysQOwnA2hRUuB7D2PsyhXFkyapgNsgqeQndX8it29HnozIDKlL-T5HfcPJiE02CXsTJ__k3sypXAqX6fvojbHi6dGswaf3jN2ecbnjm1bvNjtY_Brbhg-HdC5WVMY829Obqfs0x2gzw=w759-h1011-no?authuser=0",
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.025,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Premier amis",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Text(
                        "Last message",
                        style: Theme.of(context).textTheme.bodyText1,
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
      ),
    );
  }
}
