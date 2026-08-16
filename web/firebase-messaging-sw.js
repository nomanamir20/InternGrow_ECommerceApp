importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js');

// Same config as firebase_options.dart's web section — this runs in a
// separate service worker context, so it needs its own initialization.
firebase.initializeApp({
  apiKey: "AIzaSyBUZvm7C_S8-2a-ven1RXhW5MOQeOnkhKw",
  authDomain: "interngrow-ecommerce.firebaseapp.com",
  projectId: "interngrow-ecommerce",
  storageBucket: "interngrow-ecommerce.firebasestorage.app",
  messagingSenderId: "473413765732",
  appId: "1:473413765732:web:aed5e380e59ffc91e7ed71",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background message received:', payload);
});