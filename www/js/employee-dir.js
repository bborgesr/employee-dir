$(document).ready(function() {
  
  $(document).on('shiny:recalculating shiny:recalculate shiny:value', 
    function(event) {
      if (event.target.id === 'main') scroll(0,0);
  });
  
});