mackerel-plugin-fluentd
====

## Description

Get fluentd "monitor_agent" metrics for Mackerel.

## Usage

### Set up your fluentd

First, you should enabled monitor_agent module, and configure fluentd config file. For example is below.

```
<source>
  type monitor_agent
  bind 127.0.0.1
  port 24220
</source>
```

### Execute this plugin

And, you can execute this program

```
ruby ./mackerel-plugin-fluentd.rb
```

### Add mackerel-agent.conf

Finally, if you want to get fluentd metrics via Mackerel, please edit mackerel-agent.conf. For example is below.

```
[plugin.metrics.apache2]
command = "/path/to/ruby /path/to/mackerel-plugin-fluentd.rb"
```

## Author

[Masayuki DOI](https://github.com/mdoi)
