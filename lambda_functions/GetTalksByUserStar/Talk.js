const mongoose = require('mongoose');

const talk_schema = new mongoose.Schema({
    _id: String,
    title: String,
    url: String,
    details: String,
    main_speaker: String,
    posted: String,
    tags: Array,
    watch_next: Array,
    users_starred: Array
}, { collection: 'talks' });

module.exports = mongoose.model('talk', talk_schema);