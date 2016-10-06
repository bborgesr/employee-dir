
// Make sure the Shiny connection is established
$(document).on('shiny:connected', function(event) {

  $.get('../rstudio.csv', function(data) {
    var rstudio  = $.csv.toObjects(data);
    for (i = 0; i < rstudio.length; i++) {
      var employee = rstudio[[i]];
      var theme = "dummy";
      $('#thumbnails').append(
        '<div class="col-lg-3 col-md-4 col-xs-6 thumb">' +
          '<img class="img-responsive" id="' + employee.Photo + 
             '" src="../photos/' + employee.Photo + '.jpg">' +
        '</div>' +
        '<div class="modal" id="modal-' + employee.Photo + '" tabindex="-1" role="dialog">' +
          '<div class="modal-dialog">' +
            '<div class="modal-content">' +
              '<div class="modal-header">' +
                '<button type="button" class="close" data-dismiss="modal">&times;</button>' +
                '<h4>' + theme + ' (<a href=http://bootswatch.com/' + theme + '/>http://bootswatch.com/' + theme + '</a>)</h4>' +
              '</div>' +
              '<div class="modal-body">' +
                '<div class="prev"><p>&lt;</p></div>' +
                '<img class="modal-img" src="../photos/' + employee.Photo + '.jpg">' +
                '<div class="next"><p>&gt;</p></div>' +
              '</div>' +
            '</div><!-- /.modal-content -->' +
          '</div><!-- /.modal-dialog -->' +
        '</div><!-- /.modal -->'
      );
    }
  });
  
  $("img").on("click", function() {
    var $id = $(this).attr("id");
    $("#modal-" + $id).modal("show");
  });

  $("img + p").on("click", function() {
    var $id = $(this).prev().attr("id");
    $("#modal-" + $id).modal("show");
  });

  $(".prev").on("click", function() {
    var thisModal = $(this).parents(".modal");
    var prevModal = $(thisModal).prevAll(".modal");
    $(thisModal).modal("hide");
    if (prevModal.length > 0) {
      $(prevModal[0]).modal("show");
    }
  });

  $(".next").on("click", function() {
    var thisModal = $(this).parents(".modal");
    var nextModal = $(thisModal).nextAll(".modal");
    $(thisModal).modal("hide");
    if (nextModal.length > 0) {
      $(nextModal[0]).modal("show");
    }
  });
});
