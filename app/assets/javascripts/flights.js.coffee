$ ->
  # setup the date picker for flight departure and arrival
  $('#flight_depart_date, #flight_arrive_date').pickadate
    editable: true
    selectYears: true
    selectMonths: true
    firstDay: 1 # Monday
    formatSubmit: "yyyy-mm-dd" # Format used on submit
    hiddenName: true

  $('#flight_depart_date').on 'change', () ->
    # Read the current depart date
    depart_date = $(this).pickadate('picker').get('select')

    # Get a handle for the arrive date
    arrive_date_dp = $('#flight_arrive_date').pickadate('picker')

    # If arrive date isn't set, set it (and forget it m i rite)
    if !arrive_date_dp.get('select')
      arrive_date_dp.set('select', depart_date)

  # when flight code is set, lookup the airline
  $('#flight_flight_code').bind 'change', () ->
    $flightCode = $('#flight_flight_code')

    # strip invalid flight code chars and uppercase
    $flightCode.val () ->
      this.value.toUpperCase().replace(/\W/, '');

    airline_code = $flightCode.val().substr(0,2)

    # Lookup the airline by IATA code
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
      currentValue = element.val()
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

  $('.batch_edit_mark').bind 'change', () ->
    checked_total = $('.batch_edit_mark:checked').length

    if checked_total > 0
      $('.batch_editor .title > span').text(checked_total)

    values = $('.batch_edit_mark:checked').map(() -> $(this).val()).get().join()
    $('input[name="records_to_update"]').val(values)

  $('[name="field_to_update"]').bind 'change', () ->
    field_to_update = $(this).val();
    console.debug "Showing .batch_update_value.#{field_to_update}"
    $(".batch_update_value.#{field_to_update}").collapse('show');
    $(".batch_update_value.in:not(.#{field_to_update})").collapse('hide');
