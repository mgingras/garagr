var config = require('../config')
var nano = require('nano')(config.db);
var extend = require("xtend");

// Get
var get = function(dbName, key, callback){
	var db = nano.use(dbName);
	db.get(key, function(err, body) {
    if (err) {
      console.dir(err);
      callback({err:{status: err}});
      return;
    }
    console.dir(body);
    callback(body);
  });
}

// New thing
// eg db.post('garagr_users', {fuck: 1}, 'shit', function(data){console.dir(data)});
var post = function(dbName, data, key, callback){
  var db = nano.use(dbName);
  console.log('key: ' + key);
  console.dir(data);
  db.insert(data, key, function(err, body) {
    if(err){
      console.dir(err);
      callback({err:{status: err}});
      return;
    }
    callback(body);
  })

}

// Update thing
var put = function(dbName, data, callback){
  get(dbName, data._id, function(dbData) {
    if(data.err){
      callback(err);
      return;
    }
    post(dbName, extend(dbData, data), function(body) {
      if(body.err){
        callback(err);
        return;
      }
      callback(body);
      return;
    });
  })
}

// Delete
var del = function(dbName, data, callback){
	var db = nano.use(dbName);
}



module.exports = {
  get: get,
  post: post,
  put: put,
  del: del,
};
