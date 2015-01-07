var router = require('express').Router();

var mySql = require('mysql');
var dbConfig = require('./dbConfig');
var connection = mySql.createConnection(dbConfig);

/* GET offer listing. */
router.get('/', function(req, res) {

});

/* GET offer with given ID */
router.get('/:offerId', function(req, res) {
  res.send('respond with a resource');
});

router.post('/', function(req, res) {
  var sellerId, buyerId, amount;
  var body = req.body;
  try{
    amount = body.amount;
    buyerId = body.buyerId;
    productId = body.productId;
  } catch(e){
    return res.send({status: 'error', message: 'Invalid missing parameters in the body'});
  }

  console.log('new offer: $' + amount + ' for product '+ productId + ' by ' + buyerId);

  connection.query('INSERT INTO OFFERS(PRODUCT_ID, AMOUNT, BUYER_ID) VALUES ("'+
    productId +'", "'+
    amount +'", "'+
    buyerId + '")', function(err, rows, fields) {
      if (err) {
        return res.send({status: 'error', message: err.code});
      };
      console.dir(rows)
      res.send({status: 'ok', message: 'Successfully offered $'+ amount});
  });
});

module.exports = router;
