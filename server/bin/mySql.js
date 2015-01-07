var mysql      = require('mysql');

// var pool  = mysql.createPool({
//   connectionLimit : 10,
//   host            : 'localhost',
//   user            : 'root',
//   password        : '',
//   database        : 'garagr',
//   insecureAuth    : true,
//   connectTimeout  : 100000000
//   debug: true
// });
var connection = mysql.createConnection({
    connectionLimit : 10,
    host            : 'localhost',
    user            : 'root',
    password        : '',
    database        : 'garagr',
    insecureAuth    : true,
    connectTimeout  : 0,
    debug: true
})


module.exports = {
  getAll: function(TABLE, callback){
    pool.getConnection(function(err, connection) {
      if (err) throw err;
      connection.query('SELECT * FROM ' + TABLE, function(err, rows, fields) {
        if (err) throw err;

        console.log('SELECT * FROM ' +  TABLE +': ', rows);
        connection.end();
        callback(rows);
      });
    });
  },
  getAllWhere: function(TABLE, WHERE, callback){
    pool.getConnection(function(err, connection) {
      if (err) throw err;
      connection.query('SELECT * FROM ' + TABLE + WHERE, function(err, rows, fields) {
        if (err) throw err;

        console.log('SELECT * FROM ' +  TABLE + WHERE + ': ', rows);
        connection.release();
        callback(rows);
      });
    });
  },

  insertInto: function(TABLE, VALUES, callback){
    // console.log('here');
    // pool.getConnection(function(err, connection) {
      // if (err) {
      //   console.log('errgetConnection');
      //   return console.dir(err);
      // }
      console.log('INSERT INTO '+ TABLE +' VALUES ' + VALUES);
      connection.query('INSERT INTO '+ TABLE +' VALUES ' + VALUES, function(err, rows, fields) {
          if (err) {
            console.log('errDoQuery');
            return console.dir(err);
          };

          console.log('INSERT INTO '+ TABLE +' VALUES ' + VALUES +':', rows);
          callback(rows);
      
    });
  },
  deleteFromWhere: function(TABLE, WHERE, callback){
    pool.getConnection(function(err, connection) {
      if (err) throw err;
      connection.query('INSERT INTO '+ TABLE +' VALUES ' + VALUES, function(err, rows, fields) {
        if (err) throw err;

        console.log('INSERT INTO '+ TABLE +' VALUES ' + VALUES +':', rows);
        connection.release();
        callback(rows);
      });
    });
  }
}
