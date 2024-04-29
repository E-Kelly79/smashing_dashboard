class Dashing.Clock extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = new Date()

    time = today.toLocaleString("en-us", { hour: "numeric", minute: "numeric", timeZone: "America/New_York"});
    day = today.toLocaleString("en-us", { weekday: "long", timeZone: "America/New_York"});
    month = today.toLocaleString("en-us", { month: "long", timeZone: "America/New_York"});
    year = today.toLocaleString("en-us", { year: "numeric", timeZone: "America/New_York"});
    date = today.toLocaleString("en-us", { day: "numeric", timeZone: "America/New_York"});

    if (date == "1" || date == "21" || date == "31")
      date = date.concat("st")
    else if (date == "2" || date == "22")
      date = date.concat("nd")
    else if (date == "3" || date == "23")
      date = date.concat("rd")
    else
      date = date.concat("th")

    @set('time', time)
    @set('day', day)
    @set('date', date + " " + month)