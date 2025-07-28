import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '/utility.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorSet.pewter,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "USER DETAILS",
          style: ThisTextStyle.bold20MainBg,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 73,
                backgroundColor: colorSet.mainGold,
                child: CircleAvatar(
                  backgroundColor: colorSet.mainBG,
                  radius: 70,
                  backgroundImage:
                      const AssetImage("assets/profiles/fiska.jpg"),
                ),
              ),
              const Gap(20),
              TextField(
                cursorColor: colorSet.mainGold,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_box),
                  hintText: "Name...",
                  filled: true,
                  fillColor: colorSet.listTile1,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const Gap(20),
              TextField(
                cursorColor: colorSet.mainGold,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.house),
                  hintText: "Company Name...",
                  filled: true,
                  fillColor: colorSet.listTile1,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const Gap(20),
              TextField(
                cursorColor: colorSet.mainGold,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone),
                  hintText: "Phone Number...",
                  filled: true,
                  fillColor: colorSet.listTile1,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const Gap(20),
              TextField(
                cursorColor: colorSet.mainGold,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.mail),
                  hintText: "Email...",
                  filled: true,
                  fillColor: colorSet.listTile1,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const Gap(20),
              TextField(
                cursorColor: colorSet.mainGold,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.pin_drop),
                  hintText: "Location...",
                  filled: true,
                  fillColor: colorSet.listTile1,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const Gap(20),
              Container(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorSet.mainBG,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    print("dipencet");
                  },
                  child: Text(
                    "Save",
                    style: ThisTextStyle.bold16MainGold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
