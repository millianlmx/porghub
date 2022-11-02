// Import the functions you need from the SDKs you need
importScripts("https://www.gstatic.com/firebasejs/9.9.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.9.1/firebase-messaging-compat.js");


// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
    apiKey: "AIzaSyDAcR_m0iz3PufCFeZ9wTjjkwn-ZMS8W3o",
    authDomain: "porghub-8da18.firebaseapp.com",
    projectId: "porghub-8da18",
    storageBucket: "porghub-8da18.appspot.com",
    messagingSenderId: "338700219242",
    appId: "1:338700219242:web:605d8ed32cd705f623eb13",
    measurementId: "G-B60YW2Y3R7"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onMessage((payload) => {
    console.log('Message received. ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
        notificationOptions);
});
messaging.onBackgroundMessage(function (payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
        notificationOptions);
});