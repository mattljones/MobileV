/*
ADMIN APP USER ACCOUNTS DATATABLE
*/

// Create datatable on page load
$(function() {

  createAdminAppDataTable();

});

// Function for generating datatable - used on page load & after changes made
function createAdminAppDataTable() {

  $.getJSON("/get-all-app-users", function(data) {

    var rows = [];

    // Constructing dataset
    for (account of data) {

      // Buttons for the 'Modify' column
      var leftHTML = "<div class=\"text-center\">";
      var editButton = `<button type="button" id="${account.userID}" class="btn btn-sm btn-primary edit-button mr-1">
                          Edit
                        </button>`;
      var deleteButton = `<button type="button" id="${account.userID}" class="btn btn-sm btn-danger delete-button">
                            Delete
                          </button>`;
      var rightHTML = "</div>";
      var buttons = leftHTML + editButton + deleteButton + rightHTML;

      rows.push([account.firstName, 
                 account.lastName, 
                 account.username, 
                 account.email, 
                 account.SRO_firstName + ' ' + account.SRO_lastName, 
                 buttons]);
    };

    // Generating DataTable
    $("#table-admin-app").DataTable({
      data: rows,
      columns: [
        {title: "First Name"},
        {title: "Last Name"},
        {title: "Username"},
        {title: "Email"},
        {title: "SRO"},
        {title: "Modify"}
      ],
      language: {"lengthMenu": "Show _MENU_ accounts",
                "info": "Showing _START_ to _END_ of _TOTAL_ app user accounts",
                "infoEmpty": "Showing 0 to 0 of 0 app user accounts",
                "infoFiltered": "(filtered from _MAX_ total)",
                "zeroRecords": "No matching app user accounts found"},
      order: [[1, "asc"]],
      bDestroy: true
    });

  });

};