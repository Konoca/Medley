import 'package:flutter/material.dart';
import 'package:medley/objects/user.dart';
import 'package:medley/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

Widget accountCard(String name, Account account, Function onTap) {
  return InkWell(
    onTap: () {
      if (!account.isAuthenticated) {
        onTap();
      }
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
              Text(
                  account.isAuthenticated ? account.userName : 'Not signed in'),
            ],
          )
        ],
      ),
    ),
  );
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    UserData userData = context.watch<UserData>();
    return Column(
      children: [
        // const Text("Accounts", style: TextStyle(fontSize: 30)),
        accountCard(
          'Medley',
          userData.user,
          () {},
        ),
        accountCard(
          'Youtube',
          userData.youtubeAccount,
          () async => await userData.loginYoutube(),
        ),
        accountCard(
          'Spotify',
          userData.spotifyAccount,
          () async => await userData.loginSpotify(context),
        ),
        accountCard(
          'Soundcloud',
          userData.soundcloudAccount,
          () async => await userData.loginSoundcloud(context),
        ),
      ],
    );
  }
}
