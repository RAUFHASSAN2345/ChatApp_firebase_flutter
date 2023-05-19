import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/material.dart';

class UserProfileView extends StatefulWidget {
  final ChatUser user;
  const UserProfileView({super.key, required this.user});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Joined On: ',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: mq.width * .04),
          ),
          Text(
            MyDateUtil.getLastMsgTime(
                showYear: true, context: context, time: widget.user.createdAt),
            style: TextStyle(color: Colors.black54, fontSize: mq.width * .04),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text('${widget.user.name}'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: mq.height * .03,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .1),
              child: CachedNetworkImage(
                height: mq.height * .2,
                width: mq.height * .2,
                fit: BoxFit.cover,
                imageUrl: widget.user.image,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: mq.height * .03, bottom: mq.height * .02),
              child: Text(
                '${widget.user.email}',
                style:
                    TextStyle(color: Colors.black87, fontSize: mq.width * .05),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'About: ',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: mq.width * .04),
                ),
                Text(
                  '${widget.user.about}',
                  style: TextStyle(
                      color: Colors.black54, fontSize: mq.width * .04),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
