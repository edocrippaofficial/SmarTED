
const connectToDB = require('./db');
const talk = require('./Talk');

module.exports.addStar = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }
    
    // Check if talkId is defined
    if(!body.talkId) {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch talks. ID is null.'
        });
    }
    
    var talkId = body.talkId;
    var username = body.username;
    
    // Connect to DB
    connectToDB().then(() => {
        console.log('=> searching talk with ID ' + talkId);
        
        //  Verify the ID of the talk
        talk.countDocuments({ _id: talkId }, function (err, count) {
            console.log('ERR:', err);
            console.log('COUNT:', count);
            if (count != 1 || err){
                callback(null, {
                    statusCode: 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Unable to find talk with ID: ' + talkId
                });
                return;
            }
        });
        
        //  Get the talk and update
        talk.findByIdAndUpdate(talkId,
            { "$push": { "users_starred": username } },
            { "new": true, "upsert": false },
            function (err, log) {
                if (err){
                    callback(null, {
                        statusCode: err.statusCode || 500,
                        headers: { 'Content-Type': 'text/plain' },
                        body: 'Could not add the star. Error: ' + err
                    });
                }else{
                    callback(null, {
                        statusCode: 500,
                        headers: { 'Content-Type': 'text/plain' },
                        body: 'Star correctly added.'
                    });
                }
            }
        );
    });
};