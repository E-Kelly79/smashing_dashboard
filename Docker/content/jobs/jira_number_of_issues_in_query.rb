require 'jira-ruby'

JIRA_PROPS = {
  'url' => URI.parse("https://jira.routematch.com"),
  'username' => 'JIRAAutomation',
  'password' => 'J1r@@ut0',
  'proxy_address' => nil,
  'proxy_port' => nil
}

# the key of this mapping must be a unique identifier for your jql filter, the according value must be the jql filter id or filter name that is used in Jira
query_mapping = {
  'query1' => { 
    :query => 'status = Open AND sprint IN openSprints() AND sprint NOT IN futureSprints()'
  },
  'query2' => { 
    :query => 'resolution = Done AND sprint IN openSprints() AND sprint NOT IN futureSprints()'
  }
}

query_options = {
  :fields => [],
  :start_at => 0,
  :max_results => 100000
}

jira_options = {
  :username => JIRA_PROPS['username'],
  :password => JIRA_PROPS['password'],
  :context_path => JIRA_PROPS['url'].path,
  :site => JIRA_PROPS['url'].scheme + "://" + JIRA_PROPS['url'].host,
  :auth_type => :basic,
  :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
  :use_ssl => JIRA_PROPS['url'].scheme == 'https' ? true : false,
  :proxy_address => JIRA_PROPS['proxy_address'],
  :proxy_port => JIRA_PROPS['proxy_port']
}

open_issues_hash = Hash.new(0)
resolved_issues_hash = Hash.new(0)

query_mapping.each do |query_data_id, query|
  SCHEDULER.every '1m', :first_in => 0 do |job|
    # change this value to display different project (RDPAY1/MOD/RID/DR/PLAT)
    selected_project = "RDPAY1"
    client = JIRA::Client.new(jira_options)
    current_number_issues = client.Issue.jql(query[:query], query_options).size
    recently_opened_issues = client.Issue.jql('resolution = Unresolved AND sprint IN openSprints() AND sprint NOT IN futureSprints() AND created > startOfWeek(-2w) ORDER BY created DESC', :fields => ["key", "assignee", "summary", "issuetype", "project"], :max_results => 30)
    recently_opened_issues.each do |issue|
      assignee = issue.assignee != nil ? issue.assignee.name : "Unassigned"
      type = issue.issuetype.name
      project = issue.project.key

      if project == selected_project
      open_issues_hash[issue.key] = {avatar: "assets/#{selected_project}.png", key: issue.key, type: type, assignee: assignee, summary: issue.summary}
      end
    end
    
    recently_resolved_issues = client.Issue.jql('resolution = Done AND sprint IN openSprints() AND sprint NOT IN futureSprints() AND updated > startOfWeek(-2w) ORDER BY updated DESC', :fields => ["key", "assignee", "summary", "issuetype", "project"], :max_results => 30)
    recently_resolved_issues.each do |issue|
      assignee = issue.assignee != nil ? issue.assignee.name : "Unassigned"
      type = issue.issuetype.name
      project = issue.project.key

      if project == selected_project
      resolved_issues_hash[issue.key] = {avatar: "assets/#{selected_project}.png", key: issue.key, type: type, assignee: assignee, summary: issue.summary}
      end
    end

    send_event('query3', { items: open_issues_hash.values[0..4] })
    send_event('query4', { items: resolved_issues_hash.values[0..4]})
    send_event(query_data_id, { current: current_number_issues })
  end
end