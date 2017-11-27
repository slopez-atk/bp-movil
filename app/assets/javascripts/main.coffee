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

#  $(".ingresar-pending-trial").on 'click', (e)->
#    e.preventDefault();
#    console.log($(this).parent().parent().parent().find('form'));
#    $(this).parent().parent().parent().find('form')[0].submit();




$(document).on "best_in_place:success", (ev)->
  location.reload()

$(document).on "page:load page:fetch ready", ()->
  $(".close-parent").on "click", (ev)->
    $(this).parent().slideUp()



