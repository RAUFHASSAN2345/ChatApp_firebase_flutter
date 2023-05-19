import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/views/user_profile_view.dart';
import 'package:flutter/material.dart';

class Dialogs {
  static void snackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$msg'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void circularprogessbar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static UserProfileViewDialog(BuildContext context, ChatUser user) {
    Size mq = MediaQuery.of(context).size;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.white.withOpacity(.9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: SizedBox(
                width: mq.width * .6,
                height: mq.height * .35,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: mq.height * .05),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .35),
                          child: CachedNetworkImage(
                            width: mq.width * .5,
                            height: mq.height * .25,
                            fit: BoxFit.cover,
                            imageUrl: user.image,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) => CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: mq.width * .04,
                      top: mq.height * .02,
                      width: mq.width * .55,
                      child: Text(
                        '${user.name}',
                        style: TextStyle(
                            fontSize: mq.width * .06,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Positioned(
                        top: 6,
                        right: 8,
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfileView(user: user),
                                ));
                          },
                          shape: CircleBorder(),
                          minWidth: 0,
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ))
                  ],
                ),
              ),
            ));
  }

  static addUserUsingEmailDialog(BuildContext context) {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),
                MaterialButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (email.isNotEmpty)
                        await Api.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.snackbar(context, 'User does not exist');
                          }
                        });
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
