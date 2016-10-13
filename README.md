RStudio Employee directory: a CRUD Shiny app

CRUD can be hard to do, e.g. https://github.com/MangoTheCat/dynshiny/tree/blog

## Log of things that came up in the process
- templates, static subpages...
    - how to nagivate between different parts of the app without getting disconnected (ex: you can't go to another view - using for example location.href) --> right the only way to do this is hackish:
    
    ```r
    $(document).on( "click", ".back", function() {
      $('#main').show(); 
      $('#profile').empty();
    });
    ```
    
    - how to use nested templates
    - how to use whisker or another templating language
    
- where things should go (ex: the views)
- why the plot does not show up unless I click on the dropdown