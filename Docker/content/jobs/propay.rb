require 'nokogiri'

SCHEDULER.every '1m', first_in: 0 do |job|
  parse_page = Nokogiri::HTML(open("https://propay.statushub.io/"))
  up_no = parse_page.css(".service_circle").css(".up").css("strong").map(&:text)
  status_count = parse_page.css(".general_stat").css("strong").map(&:text)

  services = Hash.new(0)
  services["up"] = { status: "UP", count: status_count[0] }
  services["issue"] = { status: "ISSUE", count: status_count[1] }
  services["down"] = { status: "DOWN", count: status_count[2] }
  send_event("propay", items: services.values)
end