#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

puts 'Loading Rails.'

require File.dirname(__FILE__) + "/../../config/environment"
require 'net/imap'
require 'rubygems'
require 'tmail'
require 'tmail_mail_extension'

puts 'Loaded.'


$running = true
Signal.trap("TERM") do 
  $running = false
end

config = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', '..', 'config', 'mail_fetcher.yml')))

'Starting Mail Fetcher.'

while($running) do
  imap = Net::IMAP.new(config['host'], config['port'], true)
  puts "Checking for new messages."
  imap.login(config['username'], config['password'])
  
  imap.select('Inbox')
  imap.uid_search(["NOT", "DELETED"]).each do |uid|
    puts "Found message with uid: #{uid}."
    Workout.create_from_email(imap.uid_fetch(uid, 'RFC822').first.attr['RFC822'])
    imap.uid_store(uid, "+FLAGS", [:Deleted])
  end
  
  imap.logout
  puts "Sleeping for 60 seconds."
  sleep 60
end