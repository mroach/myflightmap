$ ->
  ##
  # Setup the map
  #
  if $('.airport-location-map').length
    map = null
    airport = window.airport

    initialize_map = () ->
      mapOptions =
        zoom: 4
        center: new google.maps.LatLng(airport.latitude, airport.longitude)
        mapTypeId: google.maps.MapTypeId.TERRAIN

      map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)

      new google.maps.Marker
        position: new google.maps.LatLng(airport.latitude, airport.longitude),
        map: map,
        title: airport.iata_code + " - " + airport.name + " - " + airport.city + ', ' + airport.country

    google.maps.event.addDomListener(window, 'load', initialize_map)
