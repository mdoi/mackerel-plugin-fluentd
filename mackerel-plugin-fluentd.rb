require 'open-uri'
require 'json'

class FluentdMonitor
  def initialize
    @result = {}
    @plugins = []
  end

  def parse_status
    url = "http://127.0.0.1:24220/api/plugins.json"

    index = {}
    time = Time.now.to_i
    open("#{url}") do |f|
      @result = JSON.load(f)
    end

    if @result['plugins']
      @result['plugins'].each do |p|
        if index[p['type']]
          index[p['type']] += 1
        else
          index[p['type']] = 0
        end
        name = "#{p['type']}_#{index[p['type']]}"
        if p['buffer_queue_length']
          name = "#{p['type']}_#{index[p['type']]}"
          @plugins << name unless @plugins.include?(name)
          puts ["fluentd.buffer_queue_length.#{name}", p['buffer_queue_length'], time].join("\t")
          puts ["fluentd.buffer_total_queued_size.#{name}", p['buffer_total_queued_size'], time].join("\t") if p['buffer_total_queued_size']
          puts ["fluentd.retry_count.#{name}", p['retry_count'], time].join("\t") if p['retry_count']
        end
      end
    end
  end

  def print_mackerel_graph_definition
    meta = {
      :graphs => {
        'fluentd.buffer_queue_length' => {
          :label   => 'Fluentd Buffer Queue Length',
          :unit    => 'integer',
          :metrics => [
          ]
        },
        'fluentd.buffer_total_queued_size' => {
          :label   => 'Fluentd Buffer Total Queued Size',
          :unit    => 'integer',
          :metrics => [
          ]
        },
        'fluentd.retry_count' => {
          :label   => 'Fluentd Retry Count',
          :unit    => 'integer',
          :metrics => [
          ]
        }
      }
    }

    @plugins.each do |p|
      meta[:graphs]['fluentd.buffer_queue_length'][:metrics] << {:name => p, :label => p}
      meta[:graphs]['fluentd.buffer_total_queued_size'][:metrics] << {:name => p, :label => p}
      meta[:graphs]['fluentd.retry_count'][:metrics] << {:name => p, :label => p}
    end

    puts '# mackerel-agent-plugin'
    puts meta.to_json
  end

  def print_mackerel_report
    if ENV['MACKEREL_AGENT_PLUGIN_META'] == '1'
      print_mackerel_graph_definition
      exit 0
    end
  end
end

begin
  nm = FluentdMonitor.new
  nm.parse_status
  nm.print_mackerel_report
rescue => e
  exit -1
end

