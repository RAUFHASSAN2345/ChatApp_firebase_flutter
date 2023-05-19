import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/views/user_profile_view.dart';
import 'package:chat_app/widget/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatView extends StatefulWidget {
  final ChatUser user;
  const ChatView({super.key, required this.user});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  List<Message> _list = [];
  TextEditingController _textEditingController = TextEditingController();
  bool _showEmoji = false;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: Color.fromARGB(255, 237, 247, 252),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appbarDesign(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: Api.getAllMsgs(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return SizedBox();
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                reverse: true,
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        .01),
                                itemCount: _list.length,
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    message: _list[index],
                                  );
                                },
                              );
                            } else {
                              return Center(
                                  child: Text(
                                'Say Hi! 👋',
                                style: TextStyle(fontSize: mq.width * 0.08),
                              ));
                            }
                        }
                      }),
                ),
                if (_isUploading)
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      onBackspacePressed: () {},
                      textEditingController: _textEditingController,
                      config: Config(
                        bgColor: Colors.white,
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appbarDesign() {
    Size mq = MediaQuery.of(context).size;

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileView(user: widget.user),
            ));
      },
      child: StreamBuilder(
          stream: Api.getUserLstSeen(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
            return Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black54,
                    )),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    height: mq.height * .05,
                    width: mq.height * .05,
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].itsOnline
                              ? 'Online'
                              : MyDateUtil.getLstActivetime(
                                  context: context,
                                  lastActive: list[0].lastActive)
                          : MyDateUtil.getLstActivetime(
                              context: context,
                              lastActive: widget.user.lastActive),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    )
                  ],
                )
              ],
            );
          }),
    );
  }

  Widget _chatInput() {
    Size mq = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * .03, vertical: mq.height * .01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          FocusScope.of(context).unfocus();
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 25,
                      )),
                  Expanded(
                      child: TextField(
                    onTap: () {
                      if (_showEmoji)
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                    },
                    controller: _textEditingController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintText: 'Type Something...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.blueAccent)),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> image =
                            await picker.pickMultiImage(imageQuality: 70);
                        for (var i in image) {
                          setState(() {
                            _isUploading = true;
                          });
                          Api.sentChatImage(widget.user, File(i.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          log('${image.path}');

                          Api.sentChatImage(widget.user, File(image.path));
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  SizedBox(
                    width: mq.width * .02,
                  )
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  Api.sentFirstMsgto_other_user(
                      widget.user, _textEditingController.text, Type.text);
                  _textEditingController.text = '';
                } else {
                  Api.sendMessage(
                      widget.user, _textEditingController.text, Type.text);
                }
                _textEditingController.text = '';
              }
            },
            minWidth: 0,
            padding: EdgeInsets.only(top: 13, bottom: 13, right: 8, left: 13),
            shape: CircleBorder(),
            color: Colors.green,
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
