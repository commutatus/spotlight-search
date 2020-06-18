$(document).on "turbolinks:load", () ->
  $('.select2-multiple').select2()
  $('.select2-single').select2(
    allowClear: true
  )
  $('.filter-rangepicker').daterangepicker()
  $('.datepicker').datepicker({
    format: 'dd/mm/yyyy',
    todayHighlight: true,
    autoclose: true,
  })
