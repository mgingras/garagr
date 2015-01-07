var mysql      = require('mysql');
var connection = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : '',
  database : 'garagr'
});

module.exports = {
  getAll: function(TABLE, callback){
    connection.connect();
    connection.query('SELECT * FROM ' + TABLE, function(err, rows, fields) {
      if (err) throw err;

      console.log('SELECT * FROM ' +  TABLE +': ', rows);
      callback(rows);
      connection.end();
    });
  },
  getAllWhere: function(TABLE, WHERE, callback){
    connection.connect();
    connection.query('SELECT * FROM ' + TABLE + WHERE, function(err, rows, fields) {
      if (err) throw err;

      console.log('SELECT * FROM ' +  TABLE + WHERE + ': ', rows);
      callback(rows);
      connection.end();
    });
  },
  insertInto: function(TABLE, VALUES, callback){
    connection.connect();
    connection.query('INSERT INTO '+ TABLE +' VALUES ' + VALUES, function(err, rows, fields) {
      if (err) throw err;

      console.log('INSERT INTO '+ TABLE +' VALUES ' + VALUES +':', rows);
      callback(rows);
      connection.end();
    });
  },
  deleteFromWhere: function(TABLE, WHERE, callback){
    connection.connect();
    connection.query('INSERT INTO '+ TABLE +' VALUES ' + VALUES, function(err, rows, fields) {
      if (err) throw err;

      console.log('INSERT INTO '+ TABLE +' VALUES ' + VALUES +':', rows);
      callback(rows);
      connection.end();
    });
  }

}
