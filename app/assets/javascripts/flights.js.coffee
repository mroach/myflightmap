$ ->
  # setup the date picker for flight departure and arrival
  $('#flight_depart_date, #flight_arrive_date').pickadate
    editable: true
    selectYears: true
    selectMonths: true
    firstDay: 1 # Monday
    formatSubmit: "yyyy-mm-dd" # Format used on submit
    hiddenName: true

  # when flight code is set, lookup the airline
  $('#flight_flight_code').bind 'change', () ->
    airline_code = $('#flight_flight_code').val().substr(0,2)
    $.ajax
      url: "/airlines/#{airline_code}.json"
      success: (data) ->
        $('#flight_airline_id').val(data.id)
        $('#flight_airline_name').val(data.name)
      error: () ->
        $('#flight_airline_id').val('0')
        $('#flight_airline_name').val('')

  # setup the drop-down for airports. uses AJAX to search
  $('#flight_depart_airport, #flight_arrive_airport').select2
    minimumInputLength: 3
    ajax:
      url: $(this).attr('data-source')
      dataType: "json"
      data: (term) ->
        q: term
      results: (data) ->
        results: $.map data, (item) ->
          id: item.iata_code
          text: "#{item.iata_code} - #{item.description}"
    # if there's already an airport selected (edit mode) then
    # lookup the airport and populate the list with the one option
    initSelection: (element, callback) ->
      currentValue = element.val();
      if currentValue
        $.ajax
          url: "/airports/#{currentValue}.json"
          dataType: "json"
          success: (data) ->
            callback
              id: data.iata_code
              text: "#{data.iata_code} - #{data.description}"

  # once the arrive airport is set, calculate the distance between
  $('#flight_arrive_airport').bind 'change', () ->
    $.ajax
      url: "/airports/distance_between"
      data:
        from: $('#flight_depart_airport').val()
        to: $('#flight_arrive_airport').val()
      success: (data) ->
        $('#flight_distance').val(data.distance)

  # when flight arrival time is set, calculate the duration
  $('#flight_arrive_time').bind 'change', () ->
    origin = $('#flight_depart_airport').val()
    destination = $('#flight_arrive_airport').val()
    departs = $('#flight_depart_date').val() + 'T' + $('#flight_depart_time').val()
    arrives = $('#flight_arrive_date').val() + 'T' + $('#flight_arrive_time').val()
    $.ajax
      url: "/flights/duration"
      data:
        from: origin,
        to: destination
        departs: departs
        arrives: arrives
      dataType: 'json'
      success: (data) ->
        $('#flight_duration').val(data.duration)

  # make flights clickable
  $('.flight[data-url]').bind 'click', () ->
    url = $(this).attr('data-url')
    window.location.href = url
