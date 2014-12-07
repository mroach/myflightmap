$ ->
  ##
  # Setup the map
  #
  if $('.routes-map').length
    map = null

    initialize_map = () ->
      $mapElement = $('#map-canvas')
      mapOptions =
        zoom: if $mapElement.height() > 350 then 2 else 1
        center: new google.maps.LatLng(25, 20)
        mapTypeId: google.maps.MapTypeId.TERRAIN

      map = new google.maps.Map($mapElement[0], mapOptions)
      markerBounds = new google.maps.LatLngBounds()

      for route in window.routes

        flightPlanCoordinates = [
          new google.maps.LatLng(route.from.latitude, route.from.longitude),
          new google.maps.LatLng(route.to.latitude, route.to.longitude)
        ]

        flightPath = new google.maps.Polyline
          path: flightPlanCoordinates
          geodesic: true
          strokeColor: '#A73700'
          strokeOpacity: 1.0
          strokeWeight: 1

        flightPath.setMap(map)

        addAirport(map, markerBounds, route.from)
        addAirport(map, markerBounds, route.to)

      # autozoom map to the airports of the trip
      map.fitBounds(markerBounds)

    addAirport = (map, markerBounds, airport) ->
      latLng = new google.maps.LatLng(airport.latitude, airport.longitude)

      # Add the airport to the collection of lat/lng pairs for autozoom
      markerBounds.extend(latLng)

      # Create the marker
      new google.maps.Marker
        position: latLng
        map: map
        title: airport.iata_code + " - " + airport.name + " - " + airport.city + ', ' + airport.country
        icon:
          path: google.maps.SymbolPath.CIRCLE
          scale: 3
          strokeWeight: 1

    google.maps.event.addDomListener(window, 'load', initialize_map);

  $(".big-stat").prepend('<div class="arrowbox"></div>')
