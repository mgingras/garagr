var router = require('express').Router();

var mySql = require('mysql');

var dbConfig = require('./dbConfig');
var connection = mySql.createConnection(dbConfig);

/* GET users listing. */
router.get('/', function(req, res) {
  connection.query('SELECT * FROM USERS', function(err, rows, fields) {
      if (err) {
        res.send({status: 'error', message: err.code});
      };
      console.dir(rows);
      res.send({status: 'ok', body: rows});
  });
});

/* POST username and password */
router.post('/', function(req,res) {
var query = req.query;
console.dir(query)
  if(!query.username && query.password){
    res.send({status: 'error', message: 'Invalid query parameters'});
  }
  connection.query('INSERT INTO USERS(username, password) VALUES ("'+query.username+'", "'+ query.password+'")', function(err, rows, fields) {
      if (err) {
        if(err.code === 'ER_DUP_ENTRY'){
          return res.send({status: 'error', message: 'Sorry, that username is taken.'});
        }
        return res.send({status: 'error', message: err.code});
      };
      res.send({status: 'ok', userId: rows.insertId});
  });
});

module.exports = router;
