// let datepickerSelector = '#datepicker-01';
// $(datepickerSelector).datepicker({
//   showOtherMonths: true,
//   selectOtherMonths: true,
//   dateFormat: "dd-mm-yy",
//   yearRange: '-1:+1'
// }).prev('.btn').on('click', function (e) {
//   e && e.preventDefault();
//   $(datepickerSelector).focus();
// });
//
//
// // Now let's align datepicker with the prepend button
// $(datepickerSelector).datepicker('widget').css({'margin-left': -$(datepickerSelector).prev('.btn').outerWidth()});

$(function(){
  $('#datepicker1').datepicker({
    dateFormat: "dd-mm-yy"
  }).prev('.btn').on('click', function(e){
    e && e.preventDefault();
    $('#datepicker1').focus();
  });
  $('#datepicker2').datepicker({
    dateFormat: "dd-mm-yy"
  });
});
// $('.datepick').each(function(){
//   alert("aaaa")
//   $(this).datepicker({
//     showOtherMonths: true,
//     selectOtherMonths: true,
//     dateFormat: "dd-mm-yy",
//     yearRange: '-1:+1'
//   }).prev('.btn').on('click', function (e) {
//     e && e.preventDefault();
//     $(this).focus();
//   });
// });


