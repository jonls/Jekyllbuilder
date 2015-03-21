#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'json'
require 'git'
require 'jekyll'
require 'find'

# Disable output buffering
$stdout.sync = true
$stderr.sync = true

conn = Bunny.new(:host => ENV['AMQP_PORT_5672_TCP_ADDR'],
                 :port => ENV['AMQP_PORT_5672_TCP_PORT'])
conn.start

ch = conn.create_channel
x = ch.topic('git')
q = ch.queue('', :exclusive => true)
q.bind(x, :routing_key => ENV['JEKYLL_REPO'])

puts 'Listening for push events...'

begin
  q.subscribe(:block => true) do |delivery_info, properties, body|
    push = JSON.parse(body)
    repo_name = push['repository']['full_name']
    local_url = '/git/' + repo_name + '.git'
    clone_dir = '/tmp/jekyll'
    dest_dir = '/www'

    puts 'Cloning repository ' + repo_name

    FileUtils.rm_rf clone_dir
    Git.clone(local_url, clone_dir)

    config_file = Find.find(clone_dir).find {|f| f.match(/_config\.(yaml|yml)/) }
    jekyll_dir = File.dirname(config_file)
    options = Jekyll.configuration(:source => jekyll_dir,
                                   :destination => dest_dir)
    site = Jekyll::Site.new(options)

    puts 'Building site from ' + jekyll_dir
    begin
      site.process
    rescue Jekyll::FatalException => e
      puts e.message
      FileUtils.rm_rf clone_dir
      next
    end

    puts 'Done building site in ' + dest_dir

    FileUtils.rm_rf clone_dir
  end
rescue Interrupt => _
  ch.close
  conn.close
end
