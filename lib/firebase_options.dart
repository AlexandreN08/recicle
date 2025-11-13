import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


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
    apiKey: 'AIzaSyCT4lMzkHhcdvywdVd_Q_YhtY2Wx9lNaGA',
    appId: '1:560153874536:web:aa887bbf7942614a542bdd',
    messagingSenderId: '560153874536',
    projectId: 'reciclar-23c9f',
    authDomain: 'reciclar-23c9f.firebaseapp.com',
    storageBucket: 'reciclar-23c9f.firebasestorage.app',
    measurementId: 'G-129942E77E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAH99B_gQPTz2_ACYe-qRplsO53mrhEseA',
    appId: '1:560153874536:android:c506f1086587dbb1542bdd',
    messagingSenderId: '560153874536',
    projectId: 'reciclar-23c9f',
    storageBucket: 'reciclar-23c9f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQiQeo4kNsTGDF66_3VGFhI8_uPLh0YSk',
    appId: '1:560153874536:ios:7a725a725a60ec5b542bdd',
    messagingSenderId: '560153874536',
    projectId: 'reciclar-23c9f',
    storageBucket: 'reciclar-23c9f.firebasestorage.app',
    iosClientId: '560153874536-36g98nqfncf24i2tq8av07dp0ujvbno4.apps.googleusercontent.com',
    iosBundleId: 'com.example.recicle',
  );
}
