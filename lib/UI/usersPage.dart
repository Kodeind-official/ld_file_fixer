import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '/UI/addUser.dart';
import '/UI/userDetails.dart';
import '/utility.dart';


class UsersPage extends StatefulWidget {
  @override
  State<UsersPage> createState() => _HomePageState();
}

class _HomePageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    var scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      backgroundColor: colorSet.pewter,
      key: scaffoldKey,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        title: Text(
          'USERS',
          style: ThisTextStyle.bold22MainBg,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (() => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>  AddUserPage(),
              ),
            )),
        label: Text(
          "Add User",
          style: ThisTextStyle.bold16MainGold,
        ),
        backgroundColor: colorSet.mainBG,
        icon: Icon(
          Icons.add,
          color: colorSet.mainGold,
        ),
      ),
      body: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorSet.listTile1),
                child: ListTile(
                  leading: CircleAvatar(),
                  title: Text(
                    "NAMA USER",
                    style: ThisTextStyle.bold18MainBg,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.all(10),
                  onTap: (() => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => UserDetailsPage(),
                        ),
                      )),
                ),
              ),
              const Gap(20),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorSet.listTile2),
                child: ListTile(
                  leading: CircleAvatar(),
                  title: Text(
                    "NAMA USER",
                    style: ThisTextStyle.bold18MainBg,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.all(10),
                  onTap: (() => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => UserDetailsPage(),
                        ),
                      )),
                ),
              ),
              const Gap(20),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorSet.listTile1),
                child: ListTile(
                  leading: CircleAvatar(),
                  title: Text(
                    "NAMA USER",
                    style: ThisTextStyle.bold18MainBg,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.all(10),
                  onTap: (() => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => UserDetailsPage(),
                        ),
                      )),
                ),
              ),
              const Gap(20),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorSet.listTile2),
                child: ListTile(
                  leading: CircleAvatar(),
                  title: Text(
                    "NAMA USER",
                    style: ThisTextStyle.bold18MainBg,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.all(10),
                  onTap: (() => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => UserDetailsPage(),
                        ),
                      )),
                ),
              ),
              const Gap(20),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorSet.listTile1),
                child: ListTile(
                  leading: CircleAvatar(),
                  title: Text(
                    "NAMA USER",
                    style: ThisTextStyle.bold18MainBg,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.all(10),
                  onTap: () {
                    print("dipencet");
                  },
                ),
              ),
              const Gap(20),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorSet.listTile2),
                child: ListTile(
                  leading: CircleAvatar(),
                  title: Text(
                    "NAMA USER",
                    style: ThisTextStyle.bold18MainBg,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.all(10),
                  onTap: () {
                    print("dipencet");
                  },
                ),
              ),
              const Gap(20),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorSet.listTile1),
                child: ListTile(
                  leading: CircleAvatar(),
                  title: Text(
                    "NAMA USER",
                    style: ThisTextStyle.bold18MainBg,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.all(10),
                  onTap: () {
                    print("dipencet");
                  },
                ),
              ),
              const Gap(20),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorSet.listTile2),
                child: ListTile(
                  leading: CircleAvatar(),
                  title: Text(
                    "NAMA USER",
                    style: ThisTextStyle.bold18MainBg,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.all(10),
                  onTap: () {
                    print("dipencet");
                  },
                ),
              ),
            ],
          )),
    );
  }
}
