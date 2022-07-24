import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:porghub/Screen/auth.dart';
import 'package:porghub/Screen/event.dart';
import 'package:porghub/Screen/friends.dart';
import 'package:porghub/Screen/settings.dart';
import 'package:porghub/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ColorManager(
    color: ValueNotifier<Color>(await getSeedColor()),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ColorManager.of(context).color,
      builder: (context, color, _) => MaterialApp(
        title: 'PorgHUB',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: ColorManager.of(context).color.value,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: ColorManager.of(context).color.value,
          brightness: Brightness.dark,
        ),
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data == null) {
                return const AuthPage();
              }
              return const MyHomePage(title: "PorgHUB");
            } else {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedTab = 0;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          onPressed: () {},
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) => setState(() => selectedTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.party_mode),
            label: "Évènements",
          ),
          NavigationDestination(
            icon: Icon(Icons.group),
            label: "Amis",
          ),
        ],
      ),
      body: selectedTab == 0 ? const EventPage() : const FriendsList(),
      floatingActionButton: SpeedDial(
        childPadding: const EdgeInsets.all(2.0),
        spaceBetweenChildren: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        openCloseDial: isDialOpen,
        onOpen: () => setState(() => isDialOpen.value = true),
        onClose: () => setState(() => isDialOpen.value = false),
        children: [
          SpeedDialChild(
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            label: "Créer un évènement",
            child: const Icon(Icons.list_alt),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EventCreator(),
              ),
            ),
          ),
          SpeedDialChild(
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            label: "Rejoindre un évènement",
            child: const Icon(
              Icons.group_add,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EventAdder(),
              ),
            ),
          ),
          SpeedDialChild(
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            label: "Ajouter un ami",
            child: const Icon(
              Icons.person_add,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FriendsAdder(),
              ),
            ),
          ),
        ],
        child: const Icon(Icons.add),
      ),
    );
  }
}
