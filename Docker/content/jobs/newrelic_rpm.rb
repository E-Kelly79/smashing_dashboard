require 'net/http'
require 'uri'
require 'date'

# Array of monitored application ids
app_ids = ["37185751", "77876853", "37185789"]

SCHEDULER.every '10s', first_in: 0 do |job|
  today = Date.today.to_s
  app_ids.each do |app_id|
    uri = URI.parse("https://api.newrelic.com/v2/applications/#{app_id}/metrics/data.json")
    request = Net::HTTP::Get.new(uri)
    request["X-Api-Key"] = "6bc0e85ce1966d8fe26520523bf0f3eb81621a89b2c3c14"
    request.set_form_data(
      "names[]" => ["HttpDispatcher", "Apdex"],
      "summarize" => "true",
      "from" => "#{today}T00:01:00+00:00",
      "to" => "#{today}T23:59:00+00:00",
    )
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    result = JSON.parse(response.body)

    app_metrics = Hash.new(0)
    throughput = result['metric_data']['metrics'][0]['timeslices'][0]['values']['requests_per_minute'].round(2).to_s.concat(" rpm")
    avg_resp_time = result['metric_data']['metrics'][0]['timeslices'][0]['values']['average_response_time'].round(2).to_s.concat(" ms")
    apdex = result['metric_data']['metrics'][1]['timeslices'][0]['values']['score'].round(2)
    colorOct = ((apdex*255).round(0)).to_s(16)
    apdex_color = '#FF'.concat(colorOct).concat(colorOct)

    app_metrics["#{app_id}"] = { throughput: throughput, apdex: apdex, resptime: avg_resp_time, apdexColor: apdex_color }
    send_event(app_id, items: app_metrics.values)
  end
end