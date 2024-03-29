const functions = require('firebase-functions');
require('dotenv').config();
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const bucket = admin.storage().bucket();

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
                    body: `You have only ${Math.round(+value.toString())}% of gas remaining. Schedule refill now!`
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
//                     body: `Dear ${name}, you have ${value}% of your gas left. Schedule refill now!`
//                   }).then(messages => console.log(messages.sid)).done();
        }
    }

);


//deletes the database for a user when the user has been deleted
exports.deleteUser = functions.auth.user().onDelete(async (user) => {
    const getRole = await admin.database().ref(`/roles/${user.uid}/role`).once('value');
    const role = getRole.val();
    if(role == 'user') {
        await admin.database().ref(`/users/${user.uid}`).remove();
        await admin.database().ref(`/orders/userOrders/${user.uid}`).remove();
        await admin.database().ref(`/gas_monitor/${user.uid}`).remove();
        await admin.database().ref(`/roles/${user.uid}`).remove();
        await admin.storage().bucket().file(`pictures/${user.uid}`).delete();
    }
    if(role == 'rider') {
        await admin.database().ref(`/riders/${user.uid}`).remove();
        await admin.database().ref(`/orders/riderOrders/${user.uid}`).remove();
        await admin.database().ref(`/roles/${user.uid}`).remove();
        await admin.storage().bucket().file(`pictures/${user.uid}`).delete();
    }
});


//uploads the gas_level measured from the cylinder to the database
exports.write = functions.https.onRequest(async (req, res)=> {
    let gas_level = req.query;
    const uid = gas_level.gas_monitor;
    delete gas_level.gas_monitor;
    await admin.database().ref(`gas_monitor/${uid}`).update(gas_level);
    await admin.database().ref(`gas_monitor/${uid}`).update({'lastUpdated': Date.now()});
    console.log('gas_level', gas_level);
    console.log('uid', uid);
    console.log('current date', Date.now());
});