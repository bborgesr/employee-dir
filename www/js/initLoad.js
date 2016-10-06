
// Make sure the Shiny connection is established
$(document).on('shiny:connected', function(event) {

  $.get('../rstudio.csv', function(data) {
    var rstudio  = $.csv.toObjects(data);
    for (i = 0; i < rstudio.length; i++) {
      var employee = rstudio[[i]];
      $('#thumbnails').append(
        '<div class="col-lg-3 col-md-4 col-xs-6 thumb">' +
            '<a class="thumbnail" href="#">' +
              '<img class="img-responsive" id="' + employee.Photo + 
                 '" src="../photos/' + employee.Photo + '.jpg" alt="">' +
          '</a>' +
        '</div>'
      );
      console.log(rstudio[[i]]);
    }
  });
  
  //$('#thumbnails').html(data);
});
