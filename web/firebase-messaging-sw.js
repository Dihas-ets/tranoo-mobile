importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyB5rzuZ429Fo-QN1sMbOuH_KHS4xlUP2R0',
  authDomain: 'tranoo.firebaseapp.com',
  projectId: 'tranoo',
  messagingSenderId: '532909089194',
  appId: '1:532909089194:web:d048989203cd8e23148bd3'
});

const messaging = firebase.messaging();

// Affiche la notification même si l'app est en background
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
}); 