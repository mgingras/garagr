var router = require('express').Router();
var db = require('../bin/db');
var util = require('../bin/util');
var extend = require("xtend");

/* GET home page. */
router.get('/', function(req, res) { 
  res.render('index');
  return;
});

// FB login success, set session.
router.post('/login/:id', function(req, res) {
	var id = req.params['id'];
  console.log('User with ID: ' + id + ' logged in...');
	req.session.user = JSON.parse(req.body.user);
	req.session.auth = JSON.parse(req.body.auth);

  req.session.fbAuth = true;
  db.get('garagr_users', req.session.user.id, function(data) {
    // User isnt yet signed up, sign em up...
    if(data.err){
      console.log('Error getting user with id: ' + req.session.user.id + ' signing them up...');
      res.send({status: 'success', next: '/signup'});
      return;
    }
    req.session.user = extend(data, req.session.user);
    req.session.loggedIn = true; // Logged in
    res.send({status: 'success', next: '/buySell'});
    return;
  })
});

// Logout
router.post('/logout', function(req, res) {
  req.session.destroy;
  req.session = null;
  res.send({success:true})
  return;
});

// Always called for everything
router.use(function(req, res, next) {
	if(!req.session.fbAuth){
		res.redirect('/');
		return;
	}
	next();
});

// Get Signup page, gets email/cell phone
router.get('/signup', function(req, res) {
  res.render('signup');
  // console.dir(req.session);
  return;
});

// Post signup info
router.post('/signup', function(req, res) {
  var body = req.body;
  if(!body.email){
    res.render('signup', {error: 'No Email Address submitted'});
    return;
  }
  if(!req.session.user){
    res.render('signup', {error: 'User session expired'});
    return;
  }
  if(!req.session.auth){
    res.render('signup', {error: 'Auth session expired'});
    return;
  }
  // Create account
  req.session.user.email = body.email;
  if(body.phone && body.phone !== ''){
    if(!util.validatePhone(body.phone)){
      res.render('signup', {error: 'Error, invalid phone number', email: body.email})
      return;
    }
    req.session.user.phone = body.phone.replace(/[\(\)\.\-\ ]/g, '');
  }
  db.post('garagr_users', req.session.user, req.session.user.id, function(data) {
    if(data.err){
      res.render('signup', {error: 'Error, saving user to the Databse'});
      return;
    }
    req.session.loggedIn = true;
    res.redirect('/buySell');
  });

  console.dir(req.body);

  // Handle signup data post
});

// Always called for everything
router.use(function(req, res, next) {
  if(!req.session.loggedIn){
    res.redirect('/');
    return;
  }
  next();
});


// Buy or Sell prompt page
router.get('/buySell', function(req, res) {
	req.session.prev = '/buySell';
	res.render('buySell', {
    title: 'Buy/Sell Items',
    crumbs: ['Home']
  });
	return;
});

// Get Profile Page
router.get('/profile', function(req, res) {
  // console.dir(req.session.user)
	res.render('profile', {user: req.session.user, back: req.session.prev || '/buySell', profile: true});
	return;
});

// Buy page
router.get('/buy', function(req, res) {
  res.render('buy', {
    title: 'Buy Items',
    back: '/buySell',
    crumbs: [['Home', '/buySell'], 'Buy Items']
  });
  // console.dir(req.session);
});

// Sell status page
router.get('/sell', function(req, res) {
  console.dir(req.session);
  res.render('sell', {back: 'buySell'});
  return;
});



module.exports = router;
