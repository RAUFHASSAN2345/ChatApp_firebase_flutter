import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/Dialogs.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/views/auth_views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends StatefulWidget {
  final ChatUser user;
  const ProfileView({super.key, required this.user});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  String? _profileImage;
  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          onPressed: () async {
            Dialogs.circularprogessbar(context);
            await Api.updateUserOnlineStatus(false);
            await Api.inst.signOut().then((value) async {
              await GoogleSignIn().signOut().then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                Api.inst = FirebaseAuth.instance;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginView(),
                    ));
              });
            });
          },
          icon: Icon(Icons.logout),
          label: Text('Logout'),
        ),
        body: Form(
          key: _formKey,
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        _profileImage != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(
                                  File(_profileImage!),
                                  height: mq.height * .2,
                                  width: mq.height * .2,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: CachedNetworkImage(
                                  height: mq.height * .2,
                                  width: mq.height * .2,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                ),
                              ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: MaterialButton(
                            elevation: 1,
                            shape: CircleBorder(),
                            onPressed: () {
                              _modelBottomSheet();
                            },
                            color: Colors.white,
                            child: Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: mq.height * .03, bottom: mq.height * 0.07),
                      child: Text(
                        '${widget.user.email}',
                        style: TextStyle(
                            color: Colors.black54, fontSize: mq.width * .05),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: TextFormField(
                        onSaved: (newValue) => Api.me.name = newValue ?? '',
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : 'Required Field',
                        initialValue: widget.user.name,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            hintText: 'Your Name',
                            label: Text('Name')),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, top: 20, bottom: 70),
                      child: TextFormField(
                        onSaved: (newValue) => Api.me.about = newValue ?? '',
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : 'Required Field',
                        initialValue: widget.user.about,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            hintText: 'Your About',
                            label: Text('About')),
                      ),
                    ),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            minimumSize: Size(mq.width * .4, 50)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Api.updateUserProfile().then((value) {
                              Dialogs.snackbar(
                                  context, 'Profile Updated Successfully');
                            });
                          }
                        },
                        icon: Icon(Icons.edit),
                        label: Text(
                          'Update',
                          style: TextStyle(fontSize: mq.width * .04),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _modelBottomSheet() {
    Size mq = MediaQuery.of(context).size;

    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding:
              EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
          children: [
            Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: mq.width * .06, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: mq.height * .02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * .15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        log('${image.path}');
                        setState(() {
                          _profileImage = image.path;
                        });
                        Api.updateProfilePicture(File(_profileImage!));
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/edit_image_icon.png')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * .15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        log('${image.path}');
                        setState(() {
                          _profileImage = image.path;
                        });
                        Api.updateProfilePicture(File(_profileImage!));

                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/camera_icon.png'))
              ],
            )
          ],
        );
      },
    );
  }
}
