// Load the SDK asynchronously
(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/sdk.js";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));


// This is called with the results from from FB.getLoginStatus().
function statusChangeCallback(response) {
  console.dir(response);
  console.log('statusChangeCallback: '+ response.status);
  // The response object is returned with a status field that lets the
  // app know the current login status of the person.
  // Full docs on the response object can be found in the documentation
  // for FB.getLoginStatus().
  if (response.status === 'connected') {
    // Logged into your app and Facebook.
    // testAPI();
    if (window.location.pathname !== '/') {
      return;
    };
    FB.api('/me?fields=id,name,email,picture.type(large)&access_to‌​ken=response.authResponse.accessToken', function(meResponse) {
      console.dir(response);
      console.dir(meResponse);
      // console.dir({meResponse, response.authResponse});
      var data = {
        auth: JSON.stringify(response.authResponse),
        user: JSON.stringify(meResponse)
      };
      $.post('/login/' + response.authResponse.userID, data, function(data, textStatus, jqXHR) {
        console.dir(data);
        if(data.status === 'success'){
          window.location = data.next;
        }
      });
    });

  } else if (response.status === 'not_authorized') {
    if (window.location.pathname === '/') {
      // SHOW ERROR LOGGING IN OR SOMETHING MAYBE...
      return;
    };
    // Do post to log out and destroy session...

    window.location = '/';
  } else {
    if (window.location.pathname === '/') {
      // SHOW ERROR LOGGING IN OR SOMETHING MAYBE...
      return;
    };

    // The person is not logged into Facebook, so we're not sure if
    // they are logged into this app or not.
    // Do post to log out and destroy session...
    window.location = '/';
  }
}

// This function is called when someone finishes with the Login
// Button.  See the onlogin handler attached to it in the sample
// code below.
function checkLoginState() {
  FB.getLoginStatus(function(response) {
    statusChangeCallback(response);
  });
}

window.fbAsyncInit = function() {
  FB.init({
    appId      : '1492750307644007',
    cookie     : true,  // enable cookies to allow the server to access
                        // the session
    oauth : true,
    xfbml      : true,  // parse social plugins on this page
    version    : 'v2.1' // use version 2.1
  });

  // Now that we've initialized the JavaScript SDK, we call
  // FB.getLoginStatus().  This function gets the state of the
  // person visiting this page and can return one of three states to
  // the callback you provide.  They can be:
  //
  // 1. Logged into your app ('connected')
  // 2. Logged into Facebook, but not your app ('not_authorized')
  // 3. Not logged into Facebook and can't tell if they are logged into
  //    your app or not.
  //
  // These three cases are handled in the callback function.

  FB.getLoginStatus(function(response) {
    statusChangeCallback(response);
  });

  FB.Event.subscribe('auth.authResponseChange', function(response) {
    statusChangeCallback(response);
    return;
  });

};




// Here we run a very simple test of the Graph API after login is
// successful.  See statusChangeCallback() for when this call is made.
function testAPI() {
  console.log('Welcome!  Fetching your information.... ');
  FB.api('/me', function(response) {
    console.log('Successful login for: ' + response.name);
    document.getElementById('status').innerHTML =
      'Thanks for logging in, ' + response.name + '!';
  });
}
