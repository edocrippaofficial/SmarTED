const connectToDB = require('./db');
const user = require('./User');

module.exports.getUsersByNameLike = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }
    
    // Check if a string is passed
    if(!body.search) {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch users. Input is null.'
        });
    }
    
    // Default page settings
    if (!body.doc_per_page) {
        body.doc_per_page = 10;
    }
    if (!body.page) {
        body.page = 1;
    }
    
    // Connect to DB
    connectToDB().then(() => {
        console.log('=> collecting users whose name contains ' + body.search);
        user.find({ $or: [ 
            { 'name' :       { '$regex' : body.search, $options: 'i'}},
            { 'surname' :    { '$regex' : body.search, $options: 'i'}}  
            ]})
            .skip((body.doc_per_page * body.page) - body.doc_per_page)
            .limit(body.doc_per_page)
            .then(users => {
                    console.log('=> Users: ' + users);
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