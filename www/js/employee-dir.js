$(document).ready(function() {
  
  $(document).on('shiny:recalculating', 
    function(event) {
      if (event.target.id === 'profile-profile') {
        $('#profile-profile').hide()
      }
  });
  
  $(document).on('shiny:recalculated shiny:value', 
    function(event) {
      if (event.target.id === 'profile-profile') {
        $('#profile-profile').show()
      }
  });
  
});