$(document).on "page:load page:fetch ready", ()->
  $(".best_in_place").best_in_place()

$(document).on "turbolinks:load", ()->
  $('[data-toggle="tooltip"]').tooltip("destroy").tooltip()
  $("select").selectpicker({style: 'btn-primary', menuStyle: 'dropdown-inverse'})

$(document).on "best_in_place:success", (ev)->
  location.reload()



