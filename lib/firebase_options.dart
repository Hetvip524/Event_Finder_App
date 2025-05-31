import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCZa8UTcjgs84cNLUAHtzFiOhqNrcElDY8",
    authDomain: "event-finder-app-c6d68.firebaseapp.com",
    projectId: "event-finder-app-c6d68",
    storageBucket: "event-finder-app-c6d68.firebasestorage.app",
    messagingSenderId: "956803030600",
    appId: "1:956803030600:web:70307e382d707644b2027d",
    measurementId: "G-2GQG6TQE1D"
  );
} 