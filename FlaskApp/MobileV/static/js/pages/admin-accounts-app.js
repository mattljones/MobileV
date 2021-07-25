// This file is adapted from code written for my COMP0067 group project

/*
ADMIN APP USER ACCOUNTS PAGE FUNCTIONALITY
*/

$(function() {

  // Create global variables
  var userID = "";
  var fieldsUnique = {email: true, username: true};


  // HELPER FUNCTIONS ---------------------------------------------------------

  // Checks if emails and usernames are unique in form fields
  function checkFieldsUnique(type, field) {

    currentInput = $(`#${type}-${field}`).val();

    // Submit current input for uniqueness checking
    var checkFieldsUnique = $.ajax({type: "POST",
                                    url: `/check-details-unique/app/${field}`,
                                    data: JSON.stringify({"userID": userID,
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


  // ADD APP USER ACCOUNT -----------------------------------------------------

  // On click of main page button
  $("#add-app-account").click(function(e) {

    e.preventDefault();

    // Reset modal
    $("#add-first-name").val("");
    $("#add-last-name").val("");
    $("#add-email").val("");
    $("#add-username").val("");
    $("#add-SRO-select").html("");
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
    userID = "";
    fieldsUnique["email"] = true;
    fieldsUnique["username"] = true;

    // Get list of SRO names for dropdown
    $.getJSON("/get-all-SRO-names", function(data) {

      for (account of data) {
        sroName = account.firstName + ' ' + account.lastName + ` (${account.username})`;
        $("#add-SRO-select").append(`<option value="${account.sroID}" title="${sroName}">${sroName}</option>`);
      }
      
      $("#add-app-account-modal").modal("show");

    });

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
  $("#add-app-account-form").submit(function(e) {

    e.preventDefault();
     
    var addAccount = $.ajax({type: "POST",
                             url: "/add-app-account",
                             data: JSON.stringify({'firstName': $("#add-first-name").val(),
                                                   'lastName': $("#add-last-name").val(),
                                                   'email': $("#add-email").val(),
                                                   'username': $("#add-username").val(),
                                                   'sroID': $("#add-SRO-select").val()}),
                             contentType: 'application/json;charset=UTF-8'});

    // Close modal once complete  
    addAccount.done(function(response) {
      if (response == 'success') {
        createAdminAppDataTable();
        $("#add-app-account-modal").modal("hide");
        showToast("Email sent with account details");
      };
    });

  });


  // EDIT APP USER ACCOUNT ----------------------------------------------------

  // On click of edit button in table
  $("#table-admin-app").on('click', '.edit-button', function(e) {

    e.preventDefault();

    // Reset modal
    $("#edit-first-name").val("");
    $("#edit-last-name").val("");
    $("#edit-email").val("");
    $("#edit-username").val("");
    $("#edit-SRO-select").html("");
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

    // Get userID from button
    userID = $(this).attr('id');
    
    // Reset global variables
    fieldsUnique["email"] = true;
    fieldsUnique["username"] = true;

    // Get up-to-date user data and list of SRO names for dropdown
    var accountDetails = $.getJSON(`/get-app-user-details/${userID}`);
    var sroNames = $.getJSON("/get-all-SRO-names");

    $.when(accountDetails, sroNames).done(function(accountJSON, sroJSON) {

      for (account of sroJSON[0]) {
        sroName = account.firstName + ' ' + account.lastName + ` (${account.username})`;
        $("#edit-SRO-select").append(`<option value="${account.sroID}" title="${sroName}">${sroName}</option>`);
      }

      $("#edit-first-name").val(accountJSON[0][0].firstName);
      $("#edit-last-name").val(accountJSON[0][0].lastName);
      $("#edit-email").val(accountJSON[0][0].email);
      $("#edit-username").val(accountJSON[0][0].username);
      $("#edit-SRO-select").val(accountJSON[0][0].sroID);
      
      $("#edit-app-account-modal").modal("show");

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
  $("#edit-app-account-form").submit(function(e) {

    e.preventDefault();
     
    var editAccount = $.ajax({type: "POST",
                              url: `/update-app-account/${userID}`,
                              data: JSON.stringify({'firstName': $("#edit-first-name").val(),
                                                    'lastName': $("#edit-last-name").val(),
                                                    'email': $("#edit-email").val(),
                                                    'username': $("#edit-username").val(),
                                                    'sroID': $("#edit-SRO-select").val()}),
                              contentType: 'application/json;charset=UTF-8'});

    // Close modal once complete  
    editAccount.done(function(response) {
      if (response == 'success') {
        createAdminAppDataTable();
        $("#edit-app-account-modal").modal("hide");
        showToast("Account successfully updated");
      };
    });

  });


  // DELETE APP USER ACCOUNT --------------------------------------------------

  // On click of edit button in table
  $("#table-admin-app").on('click', '.delete-button', function(e) {

    e.preventDefault();

    // Get userID from button
    userID = $(this).attr('id');

    // Reset modal
    var rowData = $(this).closest("tr").children();
    var firstName = rowData[0].innerHTML;
    var lastName = rowData[1].innerHTML;
    var username = rowData[2].innerHTML;
    $("#delete-name").html(firstName + ' ' + lastName);
    $("#delete-username").html(username);

    $("#delete-app-account-modal").modal("show");

  });

  // On submission
  $("#delete-submit").click(function() {
      
    // Submit deletion request
    var accountDeletion = $.ajax({type: "POST",
                                  url: "delete-app-account",
                                  data: JSON.stringify({'userID': userID}),
                                  contentType: 'application/json;charset=UTF-8'});
      
    // Close modal once complete  
    accountDeletion.done(function(response) {
      if (response == "success") {
        createAdminAppDataTable();
        $("#delete-app-account-modal").modal("hide");
        showToast("Account deleted");
      };
    });

  });

});