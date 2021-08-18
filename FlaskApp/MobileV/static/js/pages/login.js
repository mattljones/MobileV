/*
LOGIN PAGE FUNCTIONALITY
*/

$(function() {

  // ON SUBMISSION OF LOGIN FORM
  $("#login-form").submit(function(e) {

    e.preventDefault();

    // Get user type value from radios 
    if ($("#admin-radio").is(":checked")) {
      var user_type = 'Admin';
    }
    else {
      var user_type = 'SRO';
    };

    // Get remember me value from checkbox 
    if ($("#remember").is(":checked")) {
      var rememberMe = '1';
    }
    else {
      var rememberMe = '0';
    };

    // Get next page from URL (passed automatically by Flask)
    var queryString = window.location.search;
    var urlParams = new URLSearchParams(queryString);
    var nextPage = urlParams.get("next");
    console.log(nextPage);
      
    // Submit login request
    var loginRequest = $.ajax({type: "POST",
                               url: "/login/portal",
                               data: JSON.stringify({'user_type': user_type,
                                                     'username': $("#username").val(),
                                                     'password': $("#password").val(),
                                                     'remember_me': rememberMe,
                                                     'next_page': nextPage}),
                               contentType: 'application/json;charset=UTF-8'});

    // On completion of request
    loginRequest.done(function(response) {
      // Redirect to appropriate page for user type if successful
      if (response != "unsuccessful") {
        // window.location = response;
      } 
      // Otherwise show/flash error message
      else {
        if ($("#error-message").hasClass("d-none")){
          $("#error-message").removeClass("d-none");
        }
        else {
          $("#error-message").css("visibility", "hidden");
          setTimeout(function() {
            $("#error-message").css("visibility", "visible");
          }, 120);
        };
      };
    });

  });


  // ON CHANGE OF USER TYPE RADIO
  $("[name='user-radio']").change(function() {

    // Empty text input fields
    $("#username").val("");
    $("#password").val("");

    // Hide incorrect credential error message if was visible
    if (!$("#error-message").hasClass("d-none")){
      $("#error-message").addClass("d-none");
    };

    // Display password reset link if appropriate
    if ($("#admin-radio").is(":checked")) {
      $("#reset-password").addClass("d-none");
    } 
    else {
      $("#reset-password").removeClass("d-none");
    };

  });

  
});