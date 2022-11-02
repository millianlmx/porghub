Ici, j'introduis deux Firebase Functions pour notifier les groupes de discussions et les conversations privées.

# Notification des groupes
| URL | https://us-central1-porghub-8da18.cloudfunctions.net/notifyGroup |
| --- | ---------------------------------------------------------------- |

| arguments | groupID, groupName, userName, message |
| --- | ---------------------------------------------------------------- |
| groupId | groupId désigne l'ID, de l'évènement dans la base de données, à notifier |
| groupName | groupName désigne le nom de l'évènement |
| userName | userName désigne le pseudo de l'auteur du message |
| message | message désigne le contenu du message |

# Notification des amis
| URL | https://us-central1-porghub-8da18.cloudfunctions.net/notifyUser |
| --- | ---------------------------------------------------------------- |

| arguments | token, userID, userName, message |
| --- | ---------------------------------------------------------------- |
| token | token désigne le token de l'utilisateur à qui est destiné le message |
| userId | userId désign l'ID de l'utilisateur à qui est destiné le message |
| userName | userName désigne le pseudo de l'auteur du message |
| message | message désigne le contenu du message |
