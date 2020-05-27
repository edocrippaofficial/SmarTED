const connectToDB = require('./db');
const user = require('./User');

module.exports.getUserByID= (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }
    
    // Check if a username is passed
    if(!body.username) {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch users. Username is null.'
        });
    }
    
    // Connect to DB
    connectToDB().then(() => {
        console.log('=> collecting user with username ' + body.username);
        user.find({'username' : body.username})
            .then(user => {
                    console.log('=> User: ' + user);
                    callback(null, {
                        statusCode: 200,
                        body: JSON.stringify(user)
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