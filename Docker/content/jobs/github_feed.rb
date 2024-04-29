# coding: utf-8

require "faraday"

def symbolize_keys(hash)
  hash.inject({}){|new_hash, key_value|
    key, value = key_value
    value = symbolize_keys(value) if value.is_a?(Hash)
    new_hash[key.to_sym] = value
    new_hash
  }
end

class GithubFeed

  # Types of events displayed on feed
  EVENT_TYPES = ["PushEvent", "PullRequestEvent"]

  def initialize(user, org, token)
    @token  = token
    @user   = user
    @org    = org
    @client = Faraday.new(:url => 'https://api.github.com/')
  end

  def events
    events = json_get("/users/#{@user}/events/orgs/#{@org}")
    events.map do |event_json|
      event_type = event_json[:type]
      Object.const_get(event_type).new(event_json) if EVENT_TYPES.include?(event_type)
    end.compact
  end

  private

  def json_get(path)
    response = @client.get(path) do |req|
      req.headers['Authorization'] = "token #{@token}"
    end
    json = JSON.parse(response.body)

    if json.is_a? Array
      json.map {|j| symbolize_keys j}
    elsif json.is_a? Hash
      symbolize_keys json
    else
      raise "Only Array or Hash"
    end
  end
end

class GithubEvent
  def initialize(json_data)
    @data = json_data
  end

  def type
    @data[:type].downcase.to_sym
  end

  def date
    Time.iso8601(@data[:created_at])
  end

  def ago
    sec = (Time.now - date).floor
    if sec < 3600
      sec = sec / 60
      "#{sec} minutes ago"
    elsif sec > 3600 && sec < 86400
      hour = sec / 60 / 60
      "#{hour} hours ago"
    else
      day = sec / 60 / 60 / 24
      "#{day} days ago"
    end
  end

end

class PushEvent < GithubEvent
  def author
    @data[:actor]
  end

  def repo
    @data[:repo][:name]
  end

  def commit
    commit = symbolize_keys @data[:payload][:commits].first
    commitMsg = commit[:message]
    return commitMsg
  end

  def branch
    @data[:payload][:ref].split("/").last
  end

  def title
    "#{author[:login]} pushed to #{branch} at #{repo}"
  end

end

class PullRequestEvent < GithubEvent
  def author
    @data[:actor]
  end

  def repo
    @data[:repo][:name]
  end

  def commit
    @data[:payload][:pull_request][:title]
  end

  def title
    "#{author[:login]} opened a pull request in #{repo}"
  end

end

user         = "rmautomate"
org          = "RouteMatch"
token        = "3cb127bcb5be8938de8b499912f3e8eae07dab59"
hist_size    = 6

SCHEDULER.every '30s', :first_in => 0 do
  feed = GithubFeed.new(user, org, token)
  events = feed.events.map do |event|
    {
      message:    event.commit,
      author:     event.author[:login],
      avatar_url: event.author[:avatar_url],
      ago:        event.ago,
      title:      event.title,
    }
  end

  send_event('github_feed', {items: events[0..hist_size-1]}) unless events.empty?
end
