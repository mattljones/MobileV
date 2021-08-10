/*
RESET PASSWORD PAGE FUNCTIONALITY
*/

$(function() {

  // HIDE RETURN TO LOGIN PAGE OPTION IF APP USER------------------------------
  if (window.location.pathname.substring(16, 19) == 'app') {
    $("#login-link").addClass('d-none');
  }

  // SHOW/HIDE PASSWORD CHECKBOXES --------------------------------------------

  $(":checkbox").click(function() {
    var field = $(this).attr("id").substring(6); 
    // Show password if checked
    if ($(this).prop('checked')) {
      $(`#${field}-password`).get(0).type = 'text';
    }
    // Hide password if unchecked
    else {
      $(`#${field}-password`).get(0).type = 'password';
    }
  });


  // INPUT VALIDATION ---------------------------------------------------------

  var newPassValid = false;

  // Enable/disable submit button based on input validity
  function checkValid() {
    if (newPassValid && checkMatch()) {
      $(":submit").removeAttr("disabled");
    }
    else {
      $(":submit").attr("disabled", true);
    }
  };

  // Check if password fields match
  function checkMatch() {
    var newPass = $("#new-password").val();
    var confPass = $("#confirm-password").val();
    if (newPass === confPass & newPass != "") {
      $("#confirm-password-status").addClass("text-success");
      return true;
    }
    else {
      $("#confirm-password-status").removeClass("text-success");
      return false;
    };
  };

  // New password input validation
  $("#new-password").keyup(function() {
    var input = $("#new-password").val();
    if (input.length >= 6) {
      $("#new-password-status").addClass("text-success");
      newPassValid = true;
    }
    else {
      $("#new-password-status").removeClass("text-success");
      newPassValid = false;
    };
    checkValid();
  });

  // Confirm password input validation
  $("#confirm-password").keyup(function() {
    checkValid();
  });


  // ON SUBMISSION OF RESET PASSWORD FORM -------------------------------------
  $("#reset-password-form").submit(function(e) {

      e.preventDefault();

      var type = window.location.pathname.substring(16, 19);
      var token = window.location.pathname.substring(20);
        
      // Submit login request
      var resetPassRequest = $.ajax({type: "POST",
                                     url: `/change-password/${type}/${token}`,
                                     data: JSON.stringify({'new_password': $("#new-password").val()}),
                                     contentType: 'application/json;charset=UTF-8'});
  
      // On completion of request
      resetPassRequest.done(function(response) {
  
        if (response == "successful" && type == 'SRO') {
          $("#reset-password-form").html(`<div class="text-success text-center mb-3">
                                            <i class="fas fa-check-square mr-2"></i>
                                            Your password has been reset.
                                            <br><br>
                                            <em class="text-secondary">You will be redirected shortly...</em>
                                          </div>`);
          $("#login-link").addClass("d-none");
          setTimeout(function () {
            window.location.href = "/login";
          }, 4000);
        }

        else if (response == "successful" && type == 'app') {
          $("#reset-password-form").html(`<div class="text-success text-center mb-3">
                                            <i class="fas fa-check-square mr-2"></i>
                                            Your password has been reset.
                                            <br><br>
                                            <em class="text-secondary">You can now sign in to the app with your new password.</em>
                                          </div>`);
        }
  
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
  
});