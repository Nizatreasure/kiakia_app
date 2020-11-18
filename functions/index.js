const functions = require('firebase-functions');
require('dotenv').config();
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

        const accountSid = process.env.TWILIO_ACCOUNT_SID;
        const authToken = process.env.TWILIO_AUTH_TOKEN;
        const client = require('twilio')(accountSid, authToken);


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

//sends push notification and messages to users when their gas level is low
exports.notifyUser = functions.database.ref('/gas_monitor/{id}/gas_level')
    .onUpdate(async (snapshot, context) => {

        console.log(accountSid, authToken);
        const user_id = context.params.id;
        const oldValue = snapshot.before.val();
        const value = snapshot.after.val();

        let sendNotification = false;



        if (+oldValue.toString() > 20 && +value.toString() <= 20 && +value.toString() > 15) {
            sendNotification = true;
        }
         if (+oldValue.toString() > 15 && +value.toString() <= 15 && +value.toString() > 10) {
            sendNotification = true;
        }
        if(+oldValue.toString() > 10 && +value.toString() <= 10 && +value.toString() > 5) {
            sendNotification = true;
        }
        if (+oldValue.toString() > 5 && +value.toString() <= 5) {
            sendNotification = true;
        }


        if(sendNotification) {
            //get the device token of the user from the database
            const getDeviceToken = await admin.database().ref(`/gas_monitor/${user_id}/token`).once('value');
            const token = getDeviceToken.val();

            //get the user's phone number
            const getNumber = await admin.database().ref(`/users/${user_id}/number`).once('value');
            const number = getNumber.val();
            console.log('number is', number);

            //get the name of the user
            const profile = await admin.auth().getUser(user_id);
            name = profile.displayName;

            //create the payload of the notification to be sent to the user
            const payload = {
                notification: {
                    title: +value.toString() > 10 ? `Low gas level for ${name}!` : +value.toString() > 5 ? `Very low gas level for ${name}!` : `Critical gas level for ${name}!`,
                    body: `You have only ${Math.round(+value.toString())}% of gas remaining. Click to order immediately.`
                },
                data: {
                    'click_action': 'FLUTTER_NOTIFICATION_CLICK'
                }
            }
            await admin.messaging().sendToDevice(token, payload);
//            client.messages
//                  .create({
//                     from: 'MG5b51a5028c87ab989bf7491a9cec4fee',
//                     to: '+2349082377152',
//                     body: `Dear ${name}, you current have only ${value}% of gas left in your cylinder. Please place your order as soon as possible. \n\n Your gas partner, \n Kiakia`
//                   }).then(messages => console.log(messages.sid)).done();
        }
    }

);


//deletes the database for a user when the user has been deleted
exports.deleteUser = functions.auth.user().onDelete(async (user) => {
    await admin.database().ref(`/users/${user.uid}`).remove();
    await admin.database().ref(`/gas_monitor/${user.uid}`).remove();
});