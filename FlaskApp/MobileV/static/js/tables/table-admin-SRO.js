/*
ADMIN SRO ACCOUNTS DATATABLE
*/

// Create datatable on page load
$(function() {

  createAdminSRODataTable();

});

// Function for generating datatable - used on page load & after changes made
function createAdminSRODataTable() {

  $.getJSON("/get-all-SROs", function(data) {

    var rows = [];

    // Constructing dataset
    for (account of data) {

      // Buttons for the 'Modify' column
      var leftHTML = "<div class=\"text-center\">";
      var editButton = `<button type="button" id="${account.sroID}" class="btn btn-sm btn-primary edit-button mr-1">
                          Edit
                        </button>`;
      var deleteButton = `<button type="button" id="${account.sroID}" class="btn btn-sm btn-danger delete-button">
                            Delete
                          </button>`;
      var deleteButtonDisabled = `<button type="button" class="btn btn-sm btn-dark disabled" title="Reallocate app users" data-toggle="tooltip" data-placement="top">
                                    Delete
                                  </button>`;
      var rightHTML = "</div>";
      var buttons = leftHTML + editButton + deleteButton + rightHTML;
      var buttonsDisabled = leftHTML + editButton + deleteButtonDisabled + rightHTML;

      if (account.NumAppUsers > 0) {
        var thisButtons = buttonsDisabled; 
      }
      else {
        var thisButtons = buttons;
      };

      rows.push([account.firstName, 
                 account.lastName, 
                 account.username, 
                 account.email, 
                 account.NumAppUsers, 
                 thisButtons]);
    };

    // Generating DataTable
    $("#table-admin-SRO").DataTable({
      data: rows,
      columns: [
        {title: "First Name"},
        {title: "Last Name"},
        {title: "Username"},
        {title: "Email"},
        {title: "No. App Users"},
        {title: "Modify"}
      ],
      language: {"lengthMenu": "Show _MENU_ accounts",
                "info": "Showing _START_ to _END_ of _TOTAL_ SRO accounts",
                "infoEmpty": "Showing 0 to 0 of 0 SRO accounts",
                "infoFiltered": "(filtered from _MAX_ total)",
                "zeroRecords": "No matching SRO accounts found"},
      order: [[1, "asc"]],
      fnDrawCallback: function() {
        $("[data-toggle='tooltip']").tooltip();
      },
      bDestroy: true
    });

  });

};