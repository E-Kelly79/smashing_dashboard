SUCCESS = 'Successful'
BUILDING = 'Building'
SCHEDULED = 'Scheduled'
CANCELLED = 'Cancelled'
FAILED = 'Failed'

require 'httparty'
require 'time_difference'
require 'date'

def api_functions_deployment
  return {
    'Go' => lambda { |build_id| get_go_build_health_deployment build_id}
  }
end

def api_functions_rd
  return {
    'Go' => lambda { |build_id| get_go_build_health_rd build_id}
  }
end

def get_url(url, auth = nil)
  response = HTTParty.get(url, :basic_auth => auth)
  return JSON.parse(response.body)
end

def calculate_health(successful_count, count)
  return (successful_count / count.to_f * 100).round
end

def get_build_health_deployment(build)
  api_functions_deployment[build['server']].call(build['id'])
end

def get_build_health_rd(build)
  api_functions_rd[build['server']].call(build['id'])
end

def get_go_pipeline_status(pipeline) 
  if pipeline['stages'].index { |s| s['jobs'].index { |j| j['state'] == 'Building' } } != nil
    return BUILDING
  elsif pipeline['stages'].index { |s| s['jobs'].index { |j| j['state'] == 'Scheduled' } } != nil
    return SCHEDULED
  elsif pipeline['stages'].index { |s| s['result'] == 'Cancelled' } != nil
    return CANCELLED
  else
    return pipeline['stages'].index { |s| s['result'] == 'Failed' } == nil ? SUCCESS : FAILED
  end
end

def get_go_trigger_message(pipeline)
  return pipeline['build_cause']['trigger_message']
end

def get_go_build_health_deployment(build_id)
  url = "#{Builds::DEPLOYMENT_CONFIG['goBaseUrl']}/go/api/pipelines/#{build_id}/history"
  auth = {username: "automation", password: "Routematch2017"}
  build_info = get_url url, auth
  results = build_info['pipelines']
  successful_count = results.count { |result| get_go_pipeline_status(result) == SUCCESS }
  latest_pipeline = results[0]
  unixTimestamp = DateTime.strptime(latest_pipeline['stages'].at(0)['jobs'].at(-1)['scheduled_date'].to_s,'%Q')
  timeDifference = TimeDifference.between(unixTimestamp, DateTime.now).humanize.slice(/.*Minutes/).to_s.insert(0, "Previous run ").concat(" ago")
  approvedBy = latest_pipeline['stages'].at(0)['approved_by'].to_s.insert(0, "Approved by ")
  triggerMessage = get_go_trigger_message(latest_pipeline)
  if triggerMessage.index('<')
    triggerMessage = triggerMessage.slice(0..(triggerMessage.index(' <')))
  end

  return {
    name: latest_pipeline['name'],
    status: get_go_pipeline_status(latest_pipeline),
    link: "#{Builds::DEPLOYMENT_CONFIG['goBaseUrl']}/go/tab/pipeline/history/#{build_id}",
    health: calculate_health(successful_count, results.count),
    trigger: triggerMessage,
    difference: timeDifference,
    approvedBy: approvedBy,
  }
end

def get_go_build_health_rd(build_id)
  url = "#{Builds::RD_CONFIG['goBaseUrl']}/go/api/pipelines/#{build_id}/history"
  auth = {username: "automation", password: "Routematch2017"}
  build_info = get_url url, auth
  results = build_info['pipelines']
  successful_count = results.count { |result| get_go_pipeline_status(result) == SUCCESS }
  latest_pipeline = results[0]
  unixTimestamp = DateTime.strptime(latest_pipeline['stages'].at(0)['jobs'].at(-1)['scheduled_date'].to_s,'%Q')
  timeDifference = TimeDifference.between(unixTimestamp, DateTime.now).humanize.slice(/.*Minutes/).to_s.insert(0, "Previous run ").concat(" ago")
  approvedBy = latest_pipeline['stages'].at(0)['approved_by'].to_s.insert(0, "Approved by ")
  triggerMessage = get_go_trigger_message(latest_pipeline)
  if triggerMessage.index('<')
    triggerMessage = triggerMessage.slice(0..(triggerMessage.index(' <')))
  end

  return {
    name: latest_pipeline['name'],
    status: get_go_pipeline_status(latest_pipeline),
    link: "#{Builds::DEPLOYMENT_CONFIG['goBaseUrl']}/go/tab/pipeline/history/#{build_id}",
    health: calculate_health(successful_count, results.count),
    trigger: triggerMessage,
    difference: timeDifference,
    approvedBy: approvedBy,
  }
end

SCHEDULER.every '1m', :first_in => 0 do
  pipeline_status_deployment = Hash.new(0)
  Builds::DEPLOYMENT_LIST.each do |build|
    res =  get_build_health_deployment(build)
    if res[:status] == FAILED || res[:status] == BUILDING
      pipeline_status_deployment[res[:name]] = {label: res[:name], value: res[:status], health: res[:health], trigger: res[:trigger], difference: res[:difference], approvedBy: res[:approvedBy] }
    end
  end

  if pipeline_status_deployment.length == 0
    send_event('deployment', {items: pipeline_status_deployment.values, empty: true, passIMG: 'assets/passIMG.png' })
  else
    send_event('deployment', { items: pipeline_status_deployment.values, passIMG: '' })
  end
end

SCHEDULER.every '2m', :first_in => 0 do
  pipeline_status_rd = Hash.new(0)
  Builds::RD_LIST.each do |build|
    resp =  get_build_health_rd(build)
    if resp[:status] == FAILED || resp[:status] == BUILDING
      pipeline_status_rd[resp[:name]] = {label: resp[:name], value: resp[:status], health: resp[:health], trigger: resp[:trigger], difference: resp[:difference], approvedBy: resp[:approvedBy] }
    end
  end

  if pipeline_status_rd.length == 0
    send_event('rd', {items: pipeline_status_rd.values, empty: true, passIMG: 'assets/passIMG.png' })
  else
    send_event('rd', { items: pipeline_status_rd.values, passIMG: '' })
  end
end
