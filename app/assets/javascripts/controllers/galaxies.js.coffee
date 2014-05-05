# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.galaxies = new Object;


TSN.galaxies.show = () ->
  $("a#send_galaxy_report").bind("ajax:beforeSend", () ->
    $("a#send_galaxy_report").removeAttr("href")
    $("a#send_galaxy_report").removeAttr("remote")
    $("a#send_galaxy_report").addClass("disabled")
  )
  $("a#send_galaxy_report").bind("ajax:success", (evt, data, status, xhr) ->
    if data.success
      #replace button with success msg
      new_content = "<p class=\"text-success\"> Success your report is on it's way</p>"
    else
      #replace button with error msg
      new_content = "<p class=\"text-error\"> Sorry Something went wrong: #{data.message}</p>"
    $("a#send_galaxy_report").replaceWith(new_content)

  )

TSN.galaxies.index = () ->
  $('form input#tag').typeahead
    source: (query, callback) ->
      $.get '/galaxies/tags.json',
        search: query
      , (data) ->
        data_array = []
        for tag in data.result
          data_array.push tag.galaxy_tag.tag_text
        callback data_array
    valueField: "id" # field in items to be used for the value of the item
    labelField: "label" # field in items to be used for the displayable value of the item

