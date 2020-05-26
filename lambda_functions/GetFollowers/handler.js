const connectToDB = require('./db');
const user = require('./User');

module.exports.getFollowers = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }
    
    // Check if username is defined
    if(!body.username) {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch user. Username is null.'
        });
    }
    
    // Connect to DB
    connectToDB().then(() => {
        console.log('=> collecting users that follow ' + body.username);
        user.find({followers: body.username})
            .then(users => {
                    callback(null, {
                        statusCode: 200,
                        body: JSON.stringify(users)
                    });
                }
            )
            .catch(err =>
                callback(null, {
                    statusCode: err.statusCode || 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Could not fetch users.'
                })
            );
    });
};