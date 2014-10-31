$ ->
  $('[data-click-url]').bind 'click', (e) ->
    return if e.target.localName == "input"
    url = $(this).attr('data-click-url')
    window.location.href = url
