/*
SRO APP USER SHARES DATATABLE
*/

// Function for generating datatable - used on page load & after changes made
function createSROSharesDataTable(userID) {

  $.getJSON(`/get-app-user-shares/${userID}`, function(data) {

    var rows = [];

    // Constructing dataset
    for (share of data) {

      // Button for viewing scores or shares
      var leftHTML = "<div class=\"text-center\">";
      var button1 = `<form action="/download-app-user-share/${share.shareID}" class="mr-1 d-inline">
                       <button type="submit" class="btn btn-sm btn-primary download-share-button">
                         Download
                       </button>
                     </form>`;
      var button2 = `<a tabindex="0" type="button" class="btn btn-sm btn-danger" data-toggle="popover" data-html="true" title='<a type="button" id="${share.shareID}" class="btn btn-sm btn-danger delete-share-button">
                                                                                                                                 <i class="fas fa-trash-alt mr-1"></i>
                                                                                                                                 Confirm
                                                                                                                               </a>'>
                       Delete
                     </a>`;
      var rightHTML = "</div>";
      var buttons = leftHTML + button1 + button2 + rightHTML;

      // Reformatting date
      var dateRecorded = new Date(share.dateRecorded);
      var month = dateRecorded.getMonth() + 1;
      dateRecorded = dateRecorded.getDate() + "/" + month + "/" + dateRecorded.getFullYear();

      // Accounting for nulls being allowed in score fields
      function handleNulls(field, type) {
        if (field == null) {
          return "-";
        }
        else if (type == "name") {
          return field.toString() + ': <b>';
        }
        else {
          return field.toString() + '</b>';
        };
      };

      rows.push([dateRecorded,
                 share.testType + ' (' + share.duration + 's)', 
                 '<b>' + share.WPM + '</b>', 
                 handleNulls(share.score1_name, 'name') + handleNulls(share.score1_value, 'value'),
                 handleNulls(share.score2_name, 'name') + handleNulls(share.score2_value, 'value'),
                 handleNulls(share.score3_name, 'name') + handleNulls(share.score3_value, 'value'),
                 share.fileType, 
                 buttons]);

    };

    // Generating DataTable
    $("#table-SRO-shares").DataTable({
      data: rows,
      columns: [
        {title: "Date Recorded"},
        {title: "Share Type"},
        {title: "WPM"},
        {title: "Score 1"},
        {title: "Score 2"},
        {title: "Score 3"},
        {title: "File Type"},
        {title: "Actions"}
      ],
      columnDefs: [{ 'targets': 0, type: 'date-eu' }],
      "pageLength": 5,
      language: {"lengthMenu": "Show _MENU_ shares",
                "info": "Showing _START_ to _END_ of _TOTAL_ shares",
                "infoEmpty": "Showing 0 to 0 of 0 shares",
                "infoFiltered": "(filtered from _MAX_ total)",
                "zeroRecords": "No matching shares found"},
      order: [[0, "desc"]],
      bDestroy: true,
      "sDom": 'tp'
    });

    $('[data-toggle="popover"]').popover({
      placement : 'right',
      html: true
    });

  });

};