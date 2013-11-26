#! /usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'ruby-progressbar'

agent = Mechanize.new

print "Enter Soundcloud username: "
username = gets.chomp

print "Enter number of pages to scrape: "
count = gets.chomp

urls = {}
base = "http://soundcloud.com/#{username}"

paged_urls = (1..count.to_i).collect do |num|
  "#{base}/tracks?format=html&page=#{num}"
end

scrape_progress = ProgressBar.create(title: "Finding free downloads", total: paged_urls.count, length: 100)

paged_urls.each do |page|
  page  = agent.get(page)
  tunes = page.search('ul.tracks-list li.player')

  tunes.each do |tune|
    title = tune.css('div.info-header h3 a').text
    link  = tune.css('div.actionbar div.actions div.primary a.download')
    next if link.empty?
    urls[title] = "http://soundcloud.com" + link.attr('href')
  end

  scrape_progress.increment
end

download_progress = ProgressBar.create(total: urls.count, length: 100)
urls.each do |title, url|
  filename = "downloads/#{title}.mp3"

  unless File.exist?(filename)
    download_progress.log "Downloading #{title}"
    agent.get(url).save(filename)
  else
    download_progress.log "Skipped #{title}; already downloaded"
  end

  download_progress.increment
end
