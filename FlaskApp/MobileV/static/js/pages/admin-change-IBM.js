/*
ADMIN CHANGE IBM CREDENTIALS PAGE FUNCTIONALITY
*/

$(function() {

  $("#change-IBM-form").submit(function(e) {

    e.preventDefault();

    var new_apiKey = $("#new-api-key").val();
    var new_serviceURL = $("#new-service-url").val();

    // Submit password change request
    var changeIBMRequest = $.ajax({type: "POST",
                                    url: "/change-IBM-credentials",
                                    data: JSON.stringify({'new_apiKey': new_apiKey,
                                                          'new_serviceURL': new_serviceURL}),
                                    contentType: 'application/json;charset=UTF-8'});

    // On completion of request
    changeIBMRequest.done(function(response) {

      if (response == "successful") {
        // Update card header with new values
        if ($("#current-creds-div").hasClass("d-none")) {
          $("#current-creds-div").removeClass("d-none");
          $("#no-creds-div").addClass("d-none");
        };
        $("#current-api-key").html(new_apiKey);
        $("#current-service-url").html(new_serviceURL);
        // Reset form
        $("#new-api-key").val("");
        $("#new-service-url").val("");
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