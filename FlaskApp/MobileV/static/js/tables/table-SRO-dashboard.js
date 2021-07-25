/*
SRO DASHBOARD DATATABLE
*/

// Create datatable on page load
$(function() {

  createSRODashboardDataTable();

});

// Function for generating datatable - used on page load & after changes made
function createSRODashboardDataTable() {

  $.getJSON("/get-SRO-app-users", function(data) {

    var rows = [];

    // Constructing dataset
    for (account of data) {

      // Button for viewing scores or shares
      var leftHTML = "<div class=\"text-center\">";
      var button1 = `<button type="button" id="${account.userID}" class="btn btn-sm btn-primary edit-scores-button">
                      Edit
                    </button>`;
      var button2 = `<button type="button" id="${account.userID}" class="btn btn-sm btn-primary view-shares-button">
                      View
                    </button>`;
      var rightHTML = "</div>"; 
      var scoreButton = leftHTML + button1 + rightHTML;
      var shareButton = leftHTML + button2 + rightHTML;
      var blankSharebutton = leftHTML + "--" + rightHTML;

      // Reformatting date if not null
      if (account.MostRecent != null) {
        var date = new Date(account.MostRecent);
        var month = date.getMonth() + 1;
        date = date.getDate() + "/" + month + "/" + date.getFullYear();
      }
      else {
        var date = "--";
      };

      // Excluding share button if no shares to view
      if (account.NumShares > 0) {
        var thisShareButton = shareButton;
      }
      else {
        var thisShareButton = blankSharebutton;
      };

      rows.push([account.firstName, 
                 account.lastName, 
                 account.username,
                 scoreButton,
                 account.NumShares, 
                 date, 
                 thisShareButton]);

    };

    // Generating DataTable
    $("#table-SRO-dashboard").DataTable({
      data: rows,
      columns: [
        {title: "First Name"},
        {title: "Last Name"},
        {title: "Username"},
        {title: "Scores"},
        {title: "No. Shares"},
        {title: "Most Recent"},
        {title: "Shares"}
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