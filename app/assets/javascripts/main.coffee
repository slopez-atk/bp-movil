$(document).on "page:load page:fetch ready", ()->
  $(".best_in_place").best_in_place()

$(document).on "turbolinks:load", ()->
  $('[data-toggle="tooltip"]').tooltip("destroy").tooltip()
  $("select").selectpicker({style: 'btn-primary', menuStyle: 'dropdown-inverse'})
  $(".best_in_place").best_in_place()

  $(".nav-tabs a").on 'click',  (e)->
    e.preventDefault();
    $(this).tab("show");

  $(':checkbox').checkbox();


$(document).on "best_in_place:success", (ev)->
  location.reload()

$(document).on "page:load page:fetch ready", ()->
  $(".close-parent").on "click", (ev)->
    $(this).parent().slideUp()



