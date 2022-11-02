const functions = require("firebase-functions");
let admin = require("firebase-admin");

admin = admin.initializeApp();
const messaging = admin.messaging();

exports.notifyGroup = functions.https.onRequest((request, response) => {
  functions.logger.info("Notifying group " + request.query.groupId);
  const groupName = request.query.groupName;
  const userName = request.query.userName;
  const message = request.query.message;
  const payload = {
    notification: {
      title: "PorgHUB • " + groupName,
      body: userName + " " + message,
      icon: "https://porghub-8da18.web.app/icons/Icon-256.png",
      click_action: "https://porghub-8da18.web.app/",
    },
  };
  messaging.sendToTopic(request.query.groupId, payload).then(() => {
    functions.logger.info("Notification sent successfully");
    response.setHeader("access-control-allow-origin", "https://porghub-8da18.web.app");
    response.status(200).send("Notification sent successfully");
  }).catch((error) => {
    functions.logger.error("Error sending notification");
    response.status(503).send("Error sending notification");
  });
});

exports.notifyUser = functions.https.onRequest((request, response) => {
  functions.logger.info("Notifying user " + request.query.userId);
  const token = request.query.token;
  const userName = request.query.userName;
  const message = request.query.message;
  const payload = {
    notification: {
      title: "PorgHUB",
      body: userName + " " + message,
      icon: "https://porghub-8da18.web.app/icons/Icon-256.png",
      click_action: "https://porghub-8da18.web.app/",
    },
  };
  messaging.sendToDevice(token, payload).then(() => {
    functions.logger.info("Notification sent successfully");
    response.setHeader("access-control-allow-origin", "https://porghub-8da18.web.app");
    response.status(200).send("Notification sent successfully");
  }).catch((error) => {
    functions.logger.error("Error sending notification");
    response.status(503).send("Error sending notification");
  });
});

exports.subscribeToTopic = functions.https.onRequest((request, response) => {
  const userId = request.query.userId;
  const topic = request.query.topic;
  functions.logger.info("Subscribing user " + userId + " to topic " + topic);
  const token = request.query.token;
  messaging.subscribeToTopic(token, topic).then(() => {
    functions.logger.info("Subscribed successfully");
    response.setHeader("access-control-allow-origin", "https://porghub-8da18.web.app");
    response.status(200).send("Subscribed successfully");
  }).catch((error) => {
    functions.logger.error("Error subscribing");
    response.status(503).send("Error subscribing");
  });
});
