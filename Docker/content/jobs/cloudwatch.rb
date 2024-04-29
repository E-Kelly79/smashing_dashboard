# require './lib/cloudwatch'
 
# cw = Cloudwatch.new({
#     :access_key_id => "xxx",
#     :secret_access_key => "xxx",
#     :region => 'eu-west-1'
# })

# SCHEDULER.every '1m', :first_in => 0 do |job|

#   series = []

#   %w(NumberOfNotificationsDelivered NumberOfNotificationsFailed).each do |metric|
#     series.push(
#       cw.get_metric_data(
#         'AWS/SNS',
#         [{:name => 'TopicName', :value => 'sometopic'}],
#         metric,
#         :sum,
#         {}
#       )
#     )
#   end

#   send_event "series", { series: series }
# end