// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCgHMARjZdYAVL91A-8fLu31K6QzPx3GBU',
    appId: '1:1007159504110:web:bfd5aa2d5f82a5579c17ff',
    messagingSenderId: '1007159504110',
    projectId: 'adocao-dom',
    authDomain: 'adocao-dom.firebaseapp.com',
    storageBucket: 'adocao-dom.firebasestorage.app',
    measurementId: 'G-HHEQRJN72H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBH466fZy4vjqSodFlwgPj6NwZwkohcKpk',
    appId: '1:1007159504110:android:8f11c20ad4a5e9a19c17ff',
    messagingSenderId: '1007159504110',
    projectId: 'adocao-dom',
    storageBucket: 'adocao-dom.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjuzkvBp7jZckJ4XvxIqoE-AGc-aedK9E',
    appId: '1:1007159504110:ios:afdd846371357cfe9c17ff',
    messagingSenderId: '1007159504110',
    projectId: 'adocao-dom',
    storageBucket: 'adocao-dom.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDjuzkvBp7jZckJ4XvxIqoE-AGc-aedK9E',
    appId: '1:1007159504110:ios:afdd846371357cfe9c17ff',
    messagingSenderId: '1007159504110',
    projectId: 'adocao-dom',
    storageBucket: 'adocao-dom.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCgHMARjZdYAVL91A-8fLu31K6QzPx3GBU',
    appId: '1:1007159504110:web:db0599cebe0258b19c17ff',
    messagingSenderId: '1007159504110',
    projectId: 'adocao-dom',
    authDomain: 'adocao-dom.firebaseapp.com',
    storageBucket: 'adocao-dom.firebasestorage.app',
    measurementId: 'G-WC7FPPGLPT',
  );
}
