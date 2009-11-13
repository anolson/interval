#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

require File.dirname(__FILE__) + "/../../config/environment"
require 'net/imap'
require 'rubygems'
require 'tmail'

$running = true
Signal.trap("TERM") do 
  $running = false
end

config = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', '..', 'config', 'mail_fetcher.yml')))

while($running) do
  imap = Net::IMAP.new(config['host'], config['port'], true)
  imap.login(config['username'], config['password'])
  
  imap.select('Inbox')
  imap.uid_search(["NOT", "DELETED"]).each do |uid|
    ActiveRecord::Base.logger.info "MailFetcher - Reading message #{uid}.\n"
    mail = TMail::Mail.parse(imap.uid_fetch(uid, 'RFC822').first.attr['RFC822'])

    unless(mail.attachments.blank?)
      params = {
        :name => mail.subject,
        :performed_on => mail.date,
        :notes => mail.body.split("\n"),
        :training_files_attributes => [{:payload => mail.attachments.first.gets(nil)}]
      } 
      workout = Workout.new params
      if workout.save
        workout.process!
        WorkoutsWorker.async_process_workout(:workout_id => workout.id)
      end
    end
        
    imap.uid_store(uid, "+FLAGS", [:Deleted])
  end
  
  imap.logout
  
  ActiveRecord::Base.logger.info "MailFetcher - Sleeping for 60 seconds.\n"
  sleep 60
end