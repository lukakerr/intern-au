JS.init_app = ->

  # Searching logic
  $(".search input").on "keyup", (e) ->
    query = this.value.toLowerCase()

    # Remove all filters
    clearFilters()

    $(".companies .grid").hide()

    # For each internship
    for element in $(".companies")
      # Find company names
      companies = $(element).find(".company-name")
      for company in companies
        # Check if company name is similar to query
        if company.innerHTML.toLowerCase().indexOf(query) isnt -1
          # Show company if similar
          $(company).parent().parent().parent().show()
  
  # Filtering logic
  $(".filter span").on "click", (e) ->
    el = e.currentTarget

    # Pressed class is when filter button is coloured in
    $(el).toggleClass "pressed"

    # Get filters
    filters = getFilters(e)

    # Hide all initially
    $(".companies .grid").hide()

    # For each attribute of all internships
    for attribute in $(".attributes")
      childClasses = []

      # Get attributes of each internship
      for children in $(attribute).children()
        childClasses.push $(children)[0].className.replace("circle ", "")

      # Check if the every filter is included
      includesFilters = filters.every((val) ->
        childClasses.indexOf(val) >= 0
      )

      # Show internships with included filters
      if includesFilters
        $(attribute).parent().parent().show()

  clearFilters = ->
    for children in $(".filter").children()
      $(children).removeClass "pressed"

  getFilters = (e, filters) ->
    filters = []

    # Only push filters that are pressed
    for children in $(".filter").children()
      elClass = $(children)[0].className
      if elClass.indexOf("pressed") isnt -1
        filters.push elClass.replace("option", "").replace("pressed", "").replace(/ /g, '')

    filters