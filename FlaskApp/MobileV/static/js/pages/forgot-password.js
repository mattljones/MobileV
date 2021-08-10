/*
FORGOT PASSWORD PAGE FUNCTIONALITY
*/

$(function() {

  // ON SUBMISSION OF FORGOT PASSWORD FORM
  $("#forgot-password-form").submit(function(e) {

    e.preventDefault();
      
    // Submit login request
    var resetLinkRequest = $.ajax({type: "POST",
                                   url: "/reset-password-request/SRO",
                                   data: JSON.stringify({'email': $("#email").val()}),
                                   contentType: 'application/json;charset=UTF-8'});

    // On completion of request
    resetLinkRequest.done(function(response) {

      if (response == "successful") {
        $("#forgot-password-form").html(`<div class="text-success text-center mb-3">
                                           <i class="fas fa-check-square mr-2"></i>
                                             If that email is valid, a link has been sent.
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