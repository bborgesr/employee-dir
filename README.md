RStudio Employee directory

<!--
: a CRUD Shiny app

CRUD can be hard to do, e.g. https://github.com/MangoTheCat/dynshiny/tree/blog

## Log of things that came up in the process
- templates, static subpages...
    - how to nagivate between different parts of the app without getting disconnected (ex: you can't go to another view - using for example location.href) -> right the only way to do this is hackish:
    
    ```r
    $(document).on( "click", ".back", function() {
      $('#main').show(); 
      $('#profile').empty();
    });
    ```
    
    - how to use nested templates (should we support the current client hash in session$clientData)
    - how to use whisker or another templating language
    
- where things should go (ex: the views)
- why the plot does not show up unless I click on the dropdown (suspendWhenHidden)
- interactive graphics
- repoll github profiles?? (GitHub API has a very low rate limit)
- make leaflet map with locations (US-only)


## Pain points (to discuss in standup)
- how to use nested templates 
     - should we support the current client hash in session$clientData
     - should we put the burden on the app author's shoulders (and I demo it on this app -- push state, pop state and stuff)
     
- interactive plots (the sahred data stuff isn't available yet, right?)

- make it a CRUD app? - or is this enough?
     - have a good reason not to use dplyr because we need to alter the data, hence the need for DBI
     - or follow Gabor's thing and just levae it be
     
     
     
## features still to incorporate:
- insertUI (if we CRUD app)
- drag 'n drop image to add new employee (if we CRUD app)
- modules (how I'll include the actual app)
- tests (!!!! yes, Tareef, I know)
- repolling of GitHub (??)
- bookmark (app only) -> how does this work with subtemplates
- Rmd report (app only)

## Tensions
- between being app-driven vs. shiny-driven (i.e. Joe's suggestion that I should focus on what I want the app to do, not what Shiny can do for it): ask what can the app make for Shiny, not what Shiny can make for the app

- https://github.com/rstudio/shiny/issues/532
-->
