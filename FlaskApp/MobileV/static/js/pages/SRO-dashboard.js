// This file is adapted from code written for my COMP0067 group project

/*
SRO DASHBOARD PAGE FUNCTIONALITY
*/

$(function() {

  // Create global variables
  var userID = "";
  var originalScores = {};

  // Shows a toast with delay
  function showToast(message) {
    $("#toast-text").html(message);
    $(".toast").toast({delay: 2500});
    $(".toast").toast("show");
  };


  // EDIT APP USER SCORES -----------------------------------------------------

  // On click of edit scores button in table
  $("#table-SRO-dashboard").on('click', '.edit-scores-button', function(e) {

    e.preventDefault();

    // Reset modal
    $("#score1-radio").prop("checked", false);
    $("#score2-radio").prop("checked", false);
    $("#score3-radio").prop("checked", false);
    $("#score1").val("");
    $("#score1").prop("disabled", true);
    $("#score1").removeClass("text-danger");
    $("#score2").val("");
    $("#score2").prop("disabled", true);
    $("#score2").removeClass("text-danger");
    $("#score3").val("");
    $("#score3").prop("disabled", true);
    $("#score3").removeClass("text-danger");

    // Reset global variables
    userID = $(this).attr('id');
    originalScores = {};

    // Get scores
    $.getJSON(`/get-app-user-scores/${userID}`, function(data) {

      i = 1;
      limit = Math.max(0, data.length);

      while (i <= limit) {
        $(`#score${i}`).val(`${data[i - 1].scoreName}`);
        $(`#score${i}`).prop('disabled', false);
        $(`#score${i}-radio`).prop("checked", true);
        originalScores[i] = [data[i - 1].scoreID, data[i - 1].scoreName];
        i = i + 1;
      };

      $("#edit-scores-modal").modal("show");
  
    });

  });


  // On toggle of score radio buttons
  $("#edit-scores-form").on('click', ':checkbox', function() {
    if ($(this).is(":checked")) {
      $(this).closest(".row").find(":text").prop("disabled", false);
      $(this).closest(".row").find(":text").removeClass("text-danger");
    }
    else {
      $(this).closest(".row").find(":text").prop("disabled", true);
      $(this).closest(".row").find(":text").addClass("text-danger");
    };
  });


  // On emptying of score input field
  $("#edit-scores-form").on('keyup', ':text', function() {
    if ($(this).val() == "") {
      $(this).prop("disabled", true);
      $(this).closest(".row").find(":checkbox").prop("checked", false);
    };
  });


  // Form submission
  $("#edit-scores-form").submit(function(e) {

    e.preventDefault();

    // Getting list of inserted score names
    var inserted = [];
    i = 1;
    while (i <= 3) {
      scoreName = $(`#score${i}`).val();
      notDeleted = $(`#score${i}-radio`).is(":checked");
      notBlank = scoreName != "";
      notOriginal = !(i <= Object.keys(originalScores).length);
      if (notDeleted && notBlank && notOriginal) {
        inserted.push(scoreName);
      };
      i = i + 1;
    };

    // Getting dictionary of updated scores
    var updated = {};
    i = 1;
    limit = Math.max(0, Object.keys(originalScores).length);
    while (i <= limit) {
      scoreName = $(`#score${i}`).val();
      notDeleted = $(`#score${i}-radio`).is(":checked");
      notBlank = scoreName != "";
      changed = (scoreName != originalScores[i][1]);
      if (notDeleted && notBlank && changed) {
        updated[originalScores[i][0]] = scoreName;
      };
      i = i + 1;
    };

    // Getting list of deleted score IDs
    var deleted = [];
    i = 1;
    while (i <= 3) {
      isDeleted = !$(`#score${i}-radio`).is(":checked");
      original = (i <= Object.keys(originalScores).length);
      if (isDeleted && original) {
        deleted.push(originalScores[i][0]);
      };
      i = i + 1;
    };

    var editScores = $.ajax({type: "POST",
                             url: `/update-app-user-scores/${userID}`,
                             data: JSON.stringify({'inserted': inserted,
                                                   'deleted': deleted,
                                                   'updated': updated}),
                             contentType: 'application/json;charset=UTF-8'});

    // Close modal once complete  
    editScores.done(function(response) {
      if (response == 'success') {
        $("#edit-scores-modal").modal("hide");
        showToast("Scores successfully updated");
      };
    });

  });


  // VIEW APP USER SHARES -----------------------------------------------------


  // On click of view shares button in table
  $("#table-SRO-dashboard").on('click', '.view-shares-button', function(e) {
    e.preventDefault();
    // Reset global variables
    userID = $(this).attr('id');
    createSROSharesDataTable(userID)
    $("#view-shares-modal").modal("show");
  });

  
  // On click of delete button in popover
  $("body").on('click', '.delete-share-button', function(e) {

    var shareID = $(this).attr("id");

    var deleteShare = $.ajax({type: "POST",
                              url: "/delete-app-user-share",
                              data: JSON.stringify({'shareID': shareID}),
                              contentType: 'application/json;charset=UTF-8'});

    // Close modal once complete  
    deleteShare.done(function(response) {
      if (response == 'success') {
        $('[data-toggle="popover"]').popover("dispose");
        createSRODashboardDataTable();
        createSROSharesDataTable(userID);
      };
    });

  });

});