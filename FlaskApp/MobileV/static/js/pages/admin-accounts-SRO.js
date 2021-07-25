// This file is adapted from code written for my COMP0067 group project

/*
ADMIN SRO ACCOUNTS PAGE FUNCTIONALITY
*/

$(function() {

  // Create global variables
  var sroID = "";
  var fieldsUnique = {email: true, username: true};


  // HELPER FUNCTIONS ---------------------------------------------------------

  // Checks if emails and usernames are unique in form fields
  function checkFieldsUnique(type, field) {

    currentInput = $(`#${type}-${field}`).val();

    // Submit current input for uniqueness checking
    var checkFieldsUnique = $.ajax({type: "POST",
                                    url: `/check-details-unique/SRO/${field}`,
                                    data: JSON.stringify({"userID": sroID,
                                                          "currentInput": currentInput}),
                                    contentType: 'application/json;charset=UTF-8'});

    // Update modal as appropriate
    checkFieldsUnique.done(function(status) {
      if (status == 'unique'){
        // Enable submit button if all fields unique/valid
        fieldsUnique[`${field}`] = true;
        if (fieldsUnique.email == true && fieldsUnique.username == true) {
          $(`#${type}-submit`).prop("disabled", false)
        };
        // Update input field label
        $(`#${type}-${field}-unique-check`).removeClass("d-none");
        $(`#${type}-${field}-unique-times`).addClass("d-none");
        $(`#${type}-${field}-unique-status`).removeClass("text-danger");
        $(`#${type}-${field}-unique-status`).addClass("text-success");
      }
      else if (status == 'not_unique') {
        // Disable submit button
        fieldsUnique[`${field}`] = false;
        $(`#${type}-submit`).prop("disabled", true);
        // Update input field label
        $(`#${type}-${field}-unique-times`).removeClass("d-none");
        $(`#${type}-${field}-unique-check`).addClass("d-none");
        $(`#${type}-${field}-unique-status`).removeClass("text-success");
        $(`#${type}-${field}-unique-status`).addClass("text-danger");
      }
    });

  };

  // Shows a toast with delay
  function showToast(message) {
    $("#toast-text").removeClass("d-none");
    $("#toast-text").html(message);
    $(".toast").toast({delay: 3500});
    $(".toast").toast("show");
  };


  // ADD SRO USER ACCOUNT -----------------------------------------------------

  // On click of main page button
  $("#add-SRO-account").click(function(e) {

    e.preventDefault();

    // Reset modal
    $("#add-first-name").val("");
    $("#add-last-name").val("");
    $("#add-email").val("");
    $("#add-username").val("");
    $(`#add-email-unique-check`).removeClass("d-none");
    $(`#add-email-unique-times`).addClass("d-none");
    $(`#add-email-unique-status`).removeClass("text-danger");
    $(`#add-email-unique-status`).removeClass("text-success");
    $(`#add-email-unique-status`).addClass("text-secondary");
    $(`#add-username-unique-check`).removeClass("d-none");
    $(`#add-username-unique-times`).addClass("d-none");
    $(`#add-username-unique-status`).removeClass("text-danger");
    $(`#add-username-unique-status`).removeClass("text-success");
    $(`#add-username-unique-status`).addClass("text-secondary");
    $("#add-submit").prop("disabled", false);

    // Reset global variables
    sroID = "";
    fieldsUnique["email"] = true;
    fieldsUnique["username"] = true;
      
    $("#add-SRO-account-modal").modal("show");

  });

  // Checking email and username are unique 
  $("#add-email").keyup(function() {

    // If empty field, update modal as appropriate
    if ($("#add-email").val().length == 0) {
      $(`#add-email-unique-check`).removeClass("d-none");
      $(`#add-email-unique-times`).addClass("d-none");
      $(`#add-email-unique-status`).removeClass("text-danger");
      $(`#add-email-unique-status`).removeClass("text-success");
      $(`#add-email-unique-status`).addClass("text-secondary");
    }

    else {
      checkFieldsUnique('add', 'email');
    };

  });

  $("#add-username").keyup(function() {

    // If empty field, update modal as appropriate
    if ($("#add-username").val().length == 0) {
      $(`#add-username-unique-check`).removeClass("d-none");
      $(`#add-username-unique-times`).addClass("d-none");
      $(`#add-username-unique-status`).removeClass("text-danger");
      $(`#add-username-unique-status`).removeClass("text-success");
      $(`#add-username-unique-status`).addClass("text-secondary");
    }

    else {
      checkFieldsUnique('add', 'username');
    };

  });

  // Form submission
  $("#add-SRO-account-form").submit(function(e) {

    e.preventDefault();
      
    var addAccount = $.ajax({type: "POST",
                              url: "/add-SRO-account",
                              data: JSON.stringify({'firstName': $("#add-first-name").val(),
                                                    'lastName': $("#add-last-name").val(),
                                                    'email': $("#add-email").val(),
                                                    'username': $("#add-username").val()}),
                              contentType: 'application/json;charset=UTF-8'});

    // Close modal once complete
    addAccount.done(function(response) {
      if (response == 'success') {
        createAdminSRODataTable();
        $("#add-SRO-account-modal").modal("hide");
        showToast("Email sent with account details");
      };
    });

  });


  // EDIT SRO ACCOUNT ----------------------------------------------------

  // On click of edit button in table
  $("#table-admin-SRO").on('click', '.edit-button', function(e) {

    e.preventDefault();

    // Reset modal
    $("#edit-first-name").val("");
    $("#edit-last-name").val("");
    $("#edit-email").val("");
    $("#edit-username").val("");
    $(`#edit-email-unique-check`).removeClass("d-none");
    $(`#edit-email-unique-times`).addClass("d-none");
    $(`#edit-email-unique-status`).removeClass("text-danger");
    $(`#edit-email-unique-status`).removeClass("text-secondary");
    $(`#edit-email-unique-status`).addClass("text-success");
    $(`#edit-username-unique-check`).removeClass("d-none");
    $(`#edit-username-unique-times`).addClass("d-none");
    $(`#edit-username-unique-status`).removeClass("text-danger");
    $(`#edit-username-unique-status`).removeClass("text-secondary");
    $(`#edit-username-unique-status`).addClass("text-success");
    $("#edit-submit").prop("disabled", false);

    // Get sroID from button
    sroID = $(this).attr('id');
    
    // Reset global variables
    fieldsUnique["email"] = true;
    fieldsUnique["username"] = true;

    // Get up-to-date user data 
    $.getJSON(`/get-SRO-details/${sroID}`, function(data) {

      $("#edit-first-name").val(data[0].firstName);
      $("#edit-last-name").val(data[0].lastName);
      $("#edit-email").val(data[0].email);
      $("#edit-username").val(data[0].username);
      
      $("#edit-SRO-account-modal").modal("show");

    });

  });

  // Checking email and username are unique 
  $("#edit-email").keyup(function() {

    // If empty field, update modal as appropriate
    if ($("#edit-email").val().length == 0) {
      $(`#edit-email-unique-check`).removeClass("d-none");
      $(`#edit-email-unique-times`).addClass("d-none");
      $(`#edit-email-unique-status`).removeClass("text-danger");
      $(`#edit-email-unique-status`).removeClass("text-success");
      $(`#edit-email-unique-status`).addClass("text-secondary");
    }

    else {
      checkFieldsUnique('edit', 'email');
    };

  });

  $("#edit-username").keyup(function() {

    // If empty field, update modal as appropriate
    if ($("#edit-username").val().length == 0) {
      $(`#edit-username-unique-check`).removeClass("d-none");
      $(`#edit-username-unique-times`).addClass("d-none");
      $(`#edit-username-unique-status`).removeClass("text-danger");
      $(`#edit-username-unique-status`).removeClass("text-success");
      $(`#edit-username-unique-status`).addClass("text-secondary");
    }

    else {
      checkFieldsUnique('edit', 'username');
    };

  });

  // Form submission
  $("#edit-SRO-account-form").submit(function(e) {

    e.preventDefault();
      
    var editAccount = $.ajax({type: "POST",
                              url: `/update-SRO-account/${sroID}`,
                              data: JSON.stringify({'firstName': $("#edit-first-name").val(),
                                                    'lastName': $("#edit-last-name").val(),
                                                    'email': $("#edit-email").val(),
                                                    'username': $("#edit-username").val()}),
                              contentType: 'application/json;charset=UTF-8'});

    // Close modal once complete  
    editAccount.done(function(response) {
      if (response == 'success') {
        createAdminSRODataTable();
        $("#edit-SRO-account-modal").modal("hide");
        showToast("Account successfully updated");
      };
    });

  });


  // DELETE APP USER ACCOUNT --------------------------------------------------

  // On click of edit button in table
  $("#table-admin-SRO").on('click', '.delete-button', function(e) {

    e.preventDefault();

    // Get sroID from button
    sroID = $(this).attr('id');

    // Reset modal
    var rowData = $(this).closest("tr").children();
    var firstName = rowData[0].innerHTML;
    var lastName = rowData[1].innerHTML;
    var username = rowData[2].innerHTML;
    $("#delete-name").html(firstName + ' ' + lastName);
    $("#delete-username").html(username);

    $("#delete-SRO-account-modal").modal("show");

  });

  // On submission
  $("#delete-submit").click(function() {
      
    // Submit deletion request
    var accountDeletion = $.ajax({type: "POST",
                                  url: "delete-SRO-account",
                                  data: JSON.stringify({'sroID': sroID}),
                                  contentType: 'application/json;charset=UTF-8'});
      
    // Close modal once complete  
    accountDeletion.done(function(response) {
      if (response == "success") {
        createAdminSRODataTable();
        $("#delete-SRO-account-modal").modal("hide");
        showToast("Account deleted");
      };
    });

  });

});