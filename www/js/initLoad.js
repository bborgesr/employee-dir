
// Make sure the Shiny connection is established
$(document).on('shiny:connected', function(event) {

  function equalHeight(group) {    
    var tallest = 0;    
    group.each(function() {       
      var thisHeight = $(this).height();
      console.log(thisHeight);
      if (thisHeight > tallest) {          
        tallest = thisHeight;
        console.log(tallest);
      }    
    });    
    group.each(function() { $(this).height(tallest); });
  } 
  
  $.get('../rstudio.csv', function(data) {
    var rstudio  = $.csv.toObjects(data);
    for (i = 0; i < rstudio.length; i++) {
      var employee = rstudio[[i]];
      $('#thumbnails').append(
        '<div class="col-lg-3 col-md-4 col-xs-6 thumbnail">' +
          '<img class="img-responsive" id="' + employee.Photo + 
             '" src="../photos/' + employee.Photo + '.jpg">' +
          '<p>' + employee['First Name'] + '<br>' + 
                  employee['Last Name']+ '</p>' +
        '</div>'
      );
    }
/*
    $('.thumbnail img').waitForImages(function() {
      equalHeight($(this));
      console.log("here");
    });
*/
  });
  
/* 
  var lastEmployeeImg = $("#" + rstudio[[rstudio.length - 1]].Photo)
  .onload = function () {
    alert ("The image has loaded!");        
  };
*/
});
