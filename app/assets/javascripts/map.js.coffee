$ ->
  ##
  # Setup the map
  #
  if $('.routes-map').length
    map = null

    initialize_map = () ->
      mapOptions =
        zoom: 1
        center: new google.maps.LatLng(25, 20)
        mapTypeId: google.maps.MapTypeId.TERRAIN

      map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)

      for route in window.routes

        flightPlanCoordinates = [
          new google.maps.LatLng(route.from.latitude, route.from.longitude),
          new google.maps.LatLng(route.to.latitude, route.to.longitude)
        ]

        flightPath = new google.maps.Polyline
          path: flightPlanCoordinates
          geodesic: true
          strokeColor: '#0000FF'
          strokeOpacity: 1.0
          strokeWeight: 1

        flightPath.setMap(map)

        addAirport(map, route.from)
        addAirport(map, route.to)

    addAirport = (map, airport) ->
      new google.maps.Marker
        position: new google.maps.LatLng(airport.latitude, airport.longitude)
        map: map
        title: airport.iata_code + " - " + airport.name + " - " + airport.city + ', ' + airport.country
        icon:
          path: google.maps.SymbolPath.CIRCLE
          scale: 3
          strokeWeight: 1

    google.maps.event.addDomListener(window, 'load', initialize_map);
