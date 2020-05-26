
const connectToDB = require('./db');
const user = require('./User');

module.exports.addUserToDB = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    // Check if username is defined
    if(!event.userName) {
        console.log('=> No username provided');
        callback(null, event);
        return;
    }
    
    // Check if other fields are defined
    if (!event.request || !event.request.userAttributes) {
        console.log('=> No request field provided');
        callback(null, event);
        return;
    }
    
    // Check if name is defined
    if(!event.request.userAttributes.name) {
        console.log('=> No name provided');
        callback(null, event);
        return;
    }
    
    // Check if surname is defined
    if(!event.request.userAttributes.family_name) {
        console.log('=> No surname provided');
        callback(null, event);
        return;
    }
      
    // Check if email is defined
    if(!event.request.userAttributes['cognito:email_alias']) {
        console.log('=> No email provided');
        callback(null, event);
        return;
    }
    
    var new_user = new user({ 
        username: event.userName,
        name: event.request.userAttributes.name,
        surname: event.request.userAttributes.family_name,
        email: event.request.userAttributes['cognito:email_alias']
    });
    
    // Connect to DB
    connectToDB().then(() => {
        console.log('=> adding user ' + event.userName);
        new_user.save(function (err, saved_user) {
            if (err) {
                console.log('error: ' + err);
    
                callback(null, event);
            } else {
                console.log('user ' + event.userName + ' added correctly');
                context.succeed(event);
            }
        });
    });
};