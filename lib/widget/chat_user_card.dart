import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/helper/Dialogs.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/views/chat_msg_view.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blue.shade100,
      elevation: 0.5,
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 6),
      child: InkWell(
          // onLongPress: () async {
          //   try {
          //     if (_message == null) {
          //       await Api.sendMessage(
          //               widget.user, 'Hey, I\'m using a We Chat', Type.text)
          //           .then((value) async {
          //         await Api.deleteUser(widget.user, _message!);
          //       });
          //     } else {
          //       await Api.deleteUser(widget.user, _message!);
          //     }
          //   } catch (e) {
          //     print('error****=====$e');
          //   }
          // },
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatView(
                    user: widget.user,
                  ),
                ));
          },
          child: StreamBuilder(
            stream: Api.getLastMsg(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                  leading: InkWell(
                    onTap: () {
                      Dialogs.UserProfileViewDialog(context, widget.user);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .03),
                      child: CachedNetworkImage(
                        height: mq.height * .055,
                        width: mq.height * .055,
                        imageUrl: widget.user.image,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                      ),
                    ),
                  ),
                  title: Text('${widget.user.name}'),
                  subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? 'image'
                            : _message!.msg
                        : widget.user.about,
                    maxLines: 1,
                  ),
                  trailing: _message == null
                      ? null
                      : _message!.read.isEmpty &&
                              _message!.fromid != Api.user.uid
                          ? Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.green),
                            )
                          : Text(
                              MyDateUtil.getLastMsgTime(
                                  context: context, time: _message!.sent),
                              style: TextStyle(color: Colors.black54),
                            ));
            },
          )),
    );
  }
}
