const connectToDB = require('./db');
const user = require('./User');

module.exports.followUser = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }
    
    // Check if followed_username is defined
    if(!body.followUserName) {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch user. Username is null.'
        });
    }
    
    var followUserName = body.followUserName;
    var currentUserName = body.currentUserName;
    
    // Connect to DB
    connectToDB().then(() => {
        console.log('=> searching user with username ' + followUserName);
        
        //  Verify the username
        user.countDocuments({ "username": followUserName }, function (err, count) {
            console.log('ERR:', err);
            console.log('COUNT:', count);
            if (count != 1 || err){
                callback(null, {
                    statusCode: 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Unable to find user with username: ' + followUserName
                });
                return;
            }
        });
        
        //  Get the user and update
        user.findOneAndUpdate(
            { "username": followUserName },
            { "$push": { "followers": currentUserName } },
            { "new": true, "upsert": false },
            function (err, log) {
                if (err){
                    callback(null, {
                        statusCode: err.statusCode || 500,
                        headers: { 'Content-Type': 'text/plain' },
                        body: 'Could not follow. Error: ' + err
                    });
                }else{
                    callback(null, {
                        statusCode: 500,
                        headers: { 'Content-Type': 'text/plain' },
                        body: 'User correctly followed.'
                    });
                }
            }
        );
    });
};