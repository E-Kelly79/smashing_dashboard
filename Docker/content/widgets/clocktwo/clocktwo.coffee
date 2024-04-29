class Dashing.Clocktwo extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = new Date()

    time = today.toLocaleString("en-us", { hour: "numeric", minute: "numeric", timeZone: "Europe/Dublin"});
    day = today.toLocaleString("en-us", { weekday: "long", timeZone: "Europe/Dublin"});
    month = today.toLocaleString("en-us", { month: "long", timeZone: "Europe/Dublin"});
    year = today.toLocaleString("en-us", { year: "numeric", timeZone: "Europe/Dublin"});
    date = today.toLocaleString("en-us", { day: "numeric", timeZone: "Europe/Dublin"});

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