import 'package:flutter/material.dart';
import 'package:medley/objects/user.dart';
import 'package:medley/providers/song_provider.dart';
import 'package:medley/providers/user_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget accountCard(BuildContext context, String name, Account account, Function onTapAuth, Function onTapDeAuth) {
    return InkWell(
      onTap: () {
        if (!account.isAuthenticated) onTapAuth();
        if (account.isAuthenticated) onTapDeAuth();
        context.read<CurrentlyPlaying>().setUser(context.read<UserData>());
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF1E1E1E)),
          color: const Color(0x801E1E1E),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            const Icon(
              Icons.account_circle,
              size: 50,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(account.isAuthenticated ? account.userName : 'Not signed in'),
              ],
            )
          ],
        ),
      ),
    );
  }

  accounts(UserData userData) {
    return [
      accountCard(
        context,
        'Medley',
        userData.user,
      () {},
      () {},
      ),
      accountCard(
        context,
        'Youtube',
        userData.youtubeAccount,
      () async => await userData.loginYoutube(),
      () async => await userData.logoutYoutube(context),
      ),
      accountCard(
        context,
        'Spotify',
        userData.spotifyAccount,
      () async => await userData.loginSpotify(context),
      () async => await userData.logoutSpotify(context),
      ),
      accountCard(
        context,
        'Soundcloud',
        userData.soundcloudAccount,
      () async => await userData.loginSoundcloud(context),
      () {},
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    UserData userData = context.watch<UserData>();
    return ListView(
      children: [
        const Text("Accounts", style: TextStyle(fontSize: 30), textAlign: TextAlign.center),
        ...accounts(userData),
      ],
    );
  }
}
