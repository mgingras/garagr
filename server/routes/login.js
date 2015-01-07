var router = require('express').Router();

var mySql = require('mysql');
var dbConfig = require('./dbConfig');
var connection = mySql.createConnection(dbConfig);

/* POST username and password */
router.post('/', function(req, res) {
  console.log(req.query)
  var query = req.query;
  if(!query.username && query.password){
    res.send({status: 'error', message: 'Invalid query parameters'});
  }
  connection.query('SELECT * FROM USERS WHERE USERNAME = "' + query.username +'"', function(err, rows, fields) {
      if (err) {
        return res.send({status: 'error', message: err.code});
      };
      if(rows.length !== 1){
        return res.send({status: 'error', message: 'Invalid Username/Password'});
      }
      var user = rows[0];
      if(!(query.password === user.PASSWORD)){
        return res.send({status: 'error', message: 'Invalid Username/Password'});
      }
      res.send({status: 'ok', userId: user.ID});
  });
});


module.exports = router;
