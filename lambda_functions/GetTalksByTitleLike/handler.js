const connectToDB = require('./db');
const talk = require('./Talk');

module.exports.getTalksByTitleLike = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }
    
    // Check if search is defined
    if(!body.search) {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch talks. Search words are null.'
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
        console.log('=> collecting talks by title: ' + body.search);
        talk.find({ 'title' : { '$regex' : body.search} })
            .skip((body.doc_per_page * body.page) - body.doc_per_page)
            .limit(body.doc_per_page)
            .then(talks => {
                    callback(null, {
                        statusCode: 200,
                        body: JSON.stringify(talks)
                    });
                }
            )
            .catch(err => {
                console.log('Failed to find documents: ${err}');
                callback(null, {
                    statusCode: err.statusCode || 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Could not fetch talks'
                });
            });
    });
};