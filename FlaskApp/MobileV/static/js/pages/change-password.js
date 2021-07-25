/*
CHANGE PASSWORD FORM FUNCTIONALITY
*/

$(function() {

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


  // SUBMITTING PASSWORD CHANGE REQUEST ---------------------------------------

  $("#change-password-form").submit(function(e) {

    e.preventDefault();

    // Submit password change request
    var changePassRequest = $.ajax({type: "POST",
                                    url: "/change-password",
                                    data: JSON.stringify({'old_password': $("#current-password").val(),
                                                          'new_password': $("#new-password").val()}),
                                    contentType: 'application/json;charset=UTF-8'});

    // On completion of request
    changePassRequest.done(function(response) {

      // Show or flash error message based on visibility
      if (response == "wrong_password") {
        if ($("#error-message").hasClass("d-none")){
          $("#error-message").removeClass("d-none");
        }
        else {
          $("#error-message").css("visibility", "hidden");
          setTimeout(function() {
            $("#error-message").css("visibility", "visible");
          }, 120);
        };
      }

      else if (response == "successful") {
        // Reset form
        $("#current-password").val("");
        $("#new-password").val("");
        $("#confirm-password").val("");
        $(":checkbox").prop("checked", false);
        $("#error-message").addClass("d-none");
        $("#change-password-form").find("span").removeClass("text-success");
        newPassValid = false;
        // Show success message
        $("#success-toast").removeClass('d-none');
        $("#success-toast").toast({delay: 2300});
        $("#success-toast").toast('show');
      }

      else {
        // Show error message
        $("#success-toast").addClass('d-none');
        $("#error-toast").toast({delay: 2300});
        $("#error-toast").toast('show');
      };

    });
  
  });

});