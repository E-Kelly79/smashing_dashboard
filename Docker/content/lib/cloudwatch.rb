# require 'aws-sdk'
# require 'time'

# class Cloudwatch

#     def initialize(options)
#         @access_key_id = options[:access_key_id]
#         @secret_access_key = options[:secret_access_key]
#         @region = options[:region]
#         @clientCache = {}
#     end

#     def get_metric_data(namespace, dimensions,  metric_name, type=:average, options={})
#         if type == :average
#             statName = "Average"
#         elsif type == :sum
#             statName = "Sum"
#         elsif type == :maximum
#             statName = "Maxmimum"
#         end
#         statKey = type

#         # Get an API client instance
#         cw = @clientCache[@region]
#         if not cw
#             cw = @clientCache[@region] = Aws::CloudWatch::Client.new({
#                 region: @region,
#                 access_key_id: @access_key_id,
#                 secret_access_key: @secret_access_key
#             })
#         end

#         # Build a default set of options to pass to get_metric_statistics
#         duration = (options[:duration] or (60*60*8))
#         start_time = (options[:start_time] or (Time.now - duration))
#         end_time = (options[:end_time] or (Time.now))
#         get_metric_statistics_options = {
#             namespace: namespace ,
#             metric_name: metric_name,
#             statistics: [statName],
#             start_time: start_time.utc.iso8601,
#             end_time: end_time.utc.iso8601,
#             period: (options[:period] or (60 * 5)), # Default to 5 min stats
#             dimensions: dimensions
#         }

#         # Go get stats
#         result = cw.get_metric_statistics(get_metric_statistics_options)

#         if ((not result[:datapoints]) or (result[:datapoints].length == 0))
#             # TODO: What kind of errors can I get back?
#             puts "\e[33mWarning: Got back no data for metric #{metric_name}\e[0m"
#             answer = nil
#         else
#             # Turn the result into a Rickshaw-style series
#             data = []

#             result[:datapoints].each do |datapoint|
#                 point = {
#                     x: (datapoint[:timestamp].to_i), # time in seconds since epoch
#                     y: datapoint[statKey]
#                 }
#                 data.push point
#             end
#             data.sort! { |a,b| a[:x] <=> b[:x] }

#             answer = {
#                 name: metric_name,
#                 data: data
#             }
#         end

#         return answer
#     end

# end