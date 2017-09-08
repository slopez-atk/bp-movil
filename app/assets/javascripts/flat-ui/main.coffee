$(document).on "page:load page:fetch ready", ()->
  $(".best_in_place").best_in_place()

$(document).on "best_in_place:success", (ev)->
  location.reload()