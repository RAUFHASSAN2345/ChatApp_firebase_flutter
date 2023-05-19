import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/Dialogs.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Api.user.uid == widget.message.fromid;
    return InkWell(
      onLongPress: () {
        msgPressBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    Size mq = MediaQuery.of(context).size;
    if (widget.message.read.isEmpty) {
      Api.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightBlue),
                color: Color.fromARGB(255, 221, 245, 255),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            child: widget.message.type == Type.text
                ? Text(
                    '${widget.message.msg}',
                    style: TextStyle(
                        fontSize: mq.width * 0.05, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            '${MyDateUtil.getFormattedTime(context: context, time: widget.message.sent)}',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        )
      ],
    );
  }

  Widget _greenMessage() {
    Size mq = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),
            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
              ),
            SizedBox(
              width: 3,
            ),
            Text(
              '${MyDateUtil.getFormattedTime(context: context, time: widget.message.sent)}',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightGreen),
                color: Color.fromARGB(255, 218, 255, 176),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            child: widget.message.type == Type.text
                ? Text(
                    '${widget.message.msg}',
                    style: TextStyle(
                        fontSize: mq.width * 0.05, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void msgPressBottomSheet(bool isMe) {
    Size mq = MediaQuery.of(context).size;

    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: mq.height * .015, horizontal: mq.width * .4),
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
            widget.message.type == Type.text
                ? OptionItem(
                    context: context,
                    icon: Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Copy Message',
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        Navigator.pop(context);
                        Dialogs.snackbar(context, 'Message Copied');
                      });
                    })
                : OptionItem(
                    context: context,
                    icon: Icon(
                      Icons.download_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Save Image',
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: 'We Chat')
                            .then((success) {
                          Navigator.pop(context);
                          if (success != null && success) {
                            Dialogs.snackbar(
                                context, 'Image Successfully Saved');
                          }
                        });
                      } catch (e) {
                        print('error***$e');
                      }
                    }),
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
            if (isMe)
              OptionItem(
                  context: context,
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 26,
                  ),
                  name: 'Delete Message',
                  onTap: () async {
                    try {
                      await Api.deleteMsg(widget.message).then((value) {
                        Navigator.pop(context);
                      });
                    } catch (e) {
                      print('error******$e');
                    }
                  }),
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),
            OptionItem(
                context: context,
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.blue,
                ),
                name:
                    'Sent At: ${MyDateUtil.GetMsgTime(context: context, time: widget.message.sent)}',
                onTap: () {}),
            OptionItem(
                context: context,
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.green,
                ),
                name: widget.message.read.isEmpty
                    ? 'Read At: Not Seen Yet'
                    : 'Read At: ${MyDateUtil.GetMsgTime(context: context, time: widget.message.read)}',
                onTap: () {})
          ],
        );
      },
    );
  }
}

OptionItem(
    {required Icon icon,
    required String name,
    required onTap,
    required BuildContext context}) {
  Size mq = MediaQuery.of(context).size;

  return InkWell(
    onTap: () => onTap(),
    child: Padding(
      padding: EdgeInsets.only(
          left: mq.width * .05,
          top: mq.height * .015,
          bottom: mq.height * .015),
      child: Row(
        children: [
          icon,
          Flexible(
              child: Text(
            '    $name',
            style: TextStyle(
                color: Colors.black54, fontSize: 15, letterSpacing: 0.5),
          ))
        ],
      ),
    ),
  );
}
