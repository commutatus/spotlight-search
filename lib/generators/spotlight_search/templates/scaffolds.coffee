$(document).on "turbolinks:load", () ->
  $('.select2-multiple').select2()
  $('.select2-single').select2(
    allowClear: true
  )
  