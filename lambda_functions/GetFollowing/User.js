const mongoose = require('mongoose');

const user_schema = new mongoose.Schema({
    username: String,
    name: String,
    surname: String,
    email: String,
    followers: Array
}, { versionKey: false }, { collection: 'users' });

module.exports = mongoose.model('user', user_schema);