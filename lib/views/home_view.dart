import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/Dialogs.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/views/profile_view.dart';
import 'package:chat_app/widget/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<ChatUser> list = [];
  final List<ChatUser> _searchList = [];
  bool _issearching = false;

  @override
  void initState() {
    super.initState();
    Api.getUserInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (Api.inst.currentUser != null) {
        if (message.toString().contains('resumed'))
          Api.updateUserOnlineStatus(true);

        if (message.toString().contains('paused'))
          Api.updateUserOnlineStatus(false);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_issearching) {
            setState(() {
              _issearching = !_issearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            title: _issearching
                ? TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Name, Email, ...'),
                    autofocus: true,
                    style:
                        TextStyle(fontSize: mq.width * .05, letterSpacing: 0.5),
                    onChanged: (value) {
                      _searchList.clear();
                      for (var i in list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text(
                    'We Chat',
                  ),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _issearching = !_issearching;
                    });
                  },
                  icon: Icon(_issearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileView(
                            user: Api.me,
                          ),
                        ));
                  },
                  icon: Icon(Icons.more_vert))
            ],
          ),
          body: StreamBuilder(
            stream: Api.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  final userIds = snapshot.data?.docs.map((e) => e.id).toList();

                  if (userIds == null || userIds.isEmpty) {
                    return Center(
                      child: Text(
                        'No Connections Found',
                        style: TextStyle(fontSize: mq.width * 0.08),
                      ),
                    );
                  }
                  return StreamBuilder(
                      stream: Api.getAllUsers(userIds),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ));
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (list.isNotEmpty) {
                              return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        .01),
                                itemCount: _issearching
                                    ? _searchList.length
                                    : list.length,
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                    user: _issearching
                                        ? _searchList[index]
                                        : list[index],
                                  );
                                },
                              );
                            } else {
                              return Center(
                                  child: Text(
                                'No Connections Found',
                                style: TextStyle(fontSize: mq.width * 0.08),
                              ));
                            }
                        }
                      });
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Dialogs.addUserUsingEmailDialog(context);
            },
            child: Icon(Icons.add_comment_rounded),
          ),
        ),
      ),
    );
  }
}
