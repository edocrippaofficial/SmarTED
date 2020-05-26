// DB CONNECTION

const mongoose = require('mongoose');
mongoose.Promise = global.Promise;
let isConnected;


require('dotenv').config({ path: './variables.env' });

module.exports = connectToDB = () => {
    if (isConnected) {
        console.log('=> using already opened database connection');
        return Promise.resolve();
    }
 
    console.log('=> using new database connection');
    return mongoose.connect(process.env.DB, {dbName: 'SmarTED', useNewUrlParser: true, useUnifiedTopology: true}).then(db => {
        isConnected = db.connections[0].readyState;
    });
};