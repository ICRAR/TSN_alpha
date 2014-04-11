TSN.atMention =  (div_id) ->
  $(div_id).atwho
    at: "@"
    tpl: "<li data-value='@((${name}))'><img src='${avatar_url}' height='20' width='20'/> ${name} (${alliance_name}) </li>"
    callbacks:
      remote_filter: (query, callback) ->
        $.getJSON "/profiles/name_search.json",
          name: query
        , (data) ->
          names_array = []
          for d in data.result
            names_array.push d.profile
          callback names_array

