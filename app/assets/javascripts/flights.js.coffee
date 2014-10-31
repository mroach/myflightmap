 $ ->
  # setup the date picker for flight departure and arrival
  # $('#flight_depart_date, #flight_arrive_date').pickadate
  #   editable: true
  #   selectYears: true
  #   selectMonths: true
  #   firstDay: 1 # Monday
  #   formatSubmit: "yyyy-mm-dd" # Format used on submit
  #   hiddenName: true

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
      url: '/airports/search'
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

  # Create a selector/creator for trips
  if window.trips
    $('#flight_trip_id').select2
      data: $.map window.trips, (t) -> { id: t.id, text: t.name }
      # Allow an item that doesn't exist to be "created" on the fly
      # Previx the value with "-1:" to indicate to the controller that it needs
      # to create the trip
      createSearchChoice: (term, data) ->
        if $(data).filter(() -> this.text.localeCompare(term)==0).length == 0
          id: "-1:#{term}"
          text: term

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

  $('.batch-edit-mark').bind 'change', () ->
    checked_total = $('.batch-edit-mark:checked').length
    $editor = $('.batch-editor')
    console.debug "#{checked_total} records marked for updating"
    if checked_total == 0
      $editor.collapse('hide')
    else
      $editor.collapse('show')
      $('.title > span', $editor).text(checked_total)

      values = $('.batch-edit-mark:checked').map(() -> $(this).val()).get().join()
      $('input[name="records_to_update"]').val(values)
