$ ->
  # Yes thank you this isn't the right way to do this
  # When Modernizr 3.0 is released it'll have support for emoji detection
  # and we'll swap over to using that
  # Until then, assume only Safari supports it
  #  (Chrome identifies itself as Chrome and Safari)
  nativeEmoji = navigator.userAgent.match(/\bSafari\b/) && !navigator.userAgent.match(/\bChrome\b/)
  unless nativeEmoji
    $('.emoji').each (ix, item) ->
      twemoji.parse(item);
