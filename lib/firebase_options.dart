// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCgl2lRaUtS_uxJt15tAvEQ9R9Ci8pWMIM',
    appId: '1:1090597069226:web:df0c1d9eac4a3eb5444bd3',
    messagingSenderId: '1090597069226',
    projectId: 'chat-app-with-firebase-32c2a',
    authDomain: 'chat-app-with-firebase-32c2a.firebaseapp.com',
    storageBucket: 'chat-app-with-firebase-32c2a.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQvnVRf8XPoYxj3d3JGfqkKCtEkPB2T_I',
    appId: '1:1090597069226:android:bbe33f6358bf1f7c444bd3',
    messagingSenderId: '1090597069226',
    projectId: 'chat-app-with-firebase-32c2a',
    storageBucket: 'chat-app-with-firebase-32c2a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCOnvKp_8nEoALztn6gR6sY_NxTNtgalG0',
    appId: '1:1090597069226:ios:17e797ea8bc6612c444bd3',
    messagingSenderId: '1090597069226',
    projectId: 'chat-app-with-firebase-32c2a',
    storageBucket: 'chat-app-with-firebase-32c2a.appspot.com',
    iosClientId: '1090597069226-78g7tj0jksl11c6m2hnj4l8ecnasm8ph.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatApp',
  );
}
