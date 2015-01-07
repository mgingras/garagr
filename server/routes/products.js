var express = require('express');
var router = express.Router();

var mySql = require('mysql');
var dbConfig = require('./dbConfig');
var connection = mySql.createConnection(dbConfig);

/* GET list of proudct id. */
router.get('/', function(req, res) {
  connection.query('SELECT ID FROM PRODUCTS', function(err, rows, fields) {
      if (err) {
        res.send({status: 'error', message: err.code});
      };
      var ids = rows.map( function(product) { return product.ID; } );
      ids = shuffle(ids);
      res.send({status: 'ok', ids: ids});
  });
});

/* GET product with given ID */
router.get('/:productId', function(req, res) {
  var id = req.params['productId'];
  console.log(id);
  connection.query('SELECT * FROM PRODUCTS WHERE ID=' + id, function(err, rows, fields) {
    if (err) {
        res.send({status: 'error', message: err.code});
      };
      if(rows.length !== 1){
        res.send({status: 'error', message: "Did not find matching product"});
      }
      res.send({status: 'ok', productName: rows[0].PRODUCT_NAME, productDescription: rows[0].DESCRIPTION, price: rows[0].ASKING_PRICE, image: rows[0].IMAGE, sellerId: rows[0].SELLER_ID });
  });
});

router.post('/', function(req, res) {

  var productName, productDescription, productPrice, productImage, sellerId;
  var body = req.body;
  try{
    productName = body.name;
    productDescription = body.description;
    productPrice = body.amount;
    productImage = body.image;
    sellerId = body.seller
  } catch(e){
    return res.send({status: 'error', message: 'Invalid missing parameters in the body'});
  }
  console.log('New Product: ' + productName + '\nDescription: ' + productDescription + '\n$' + productPrice + '\nImage: ' + productImage.filename + '\nSeller: ' + sellerId);

  connection.query('INSERT INTO PRODUCTS(PRODUCT_NAME, DESCRIPTION, ASKING_PRICE, IMAGE, SELLER_ID) VALUES ("'+
    productName +'", "'+
    productDescription +'", "'+
    productPrice +'", "'+
    productImage.file_data +'", "'+
    sellerId  +'")', function(err, rows, fields) {
      if (err) {
        return res.send({status: 'error', message: err.code});
      };
      console.dir(rows)
      res.send({status: 'ok', productId: rows.insertId, message: "Product successfully uploaded"});
  });
});

module.exports = router;


function shuffle(array) {
  var currentIndex = array.length, temporaryValue, randomIndex ;

  // While there remain elements to shuffle...
  while (0 !== currentIndex) {

    // Pick a remaining element...
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex -= 1;

    // And swap it with the current element.
    temporaryValue = array[currentIndex];
    array[currentIndex] = array[randomIndex];
    array[randomIndex] = temporaryValue;
  }

  return array;
}
