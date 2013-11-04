#! /usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'mechanize'

# realtime output
$stdout.sync = true

downloader = Mechanize.new
downloader.pluggable_parser.default = Mechanize::Download

print "Enter Soundcloud username: "
username = gets.chomp

urls = {}
base = "http://soundcloud.com/#{username}"
num = 1

print "Collecting track list "
begin
  url = "#{base}/tracks?format=html&page=#{num}"
  page = Nokogiri::HTML(open(url))
  tunes = page.css('ul.tracks-list li.player')
  tunes.each do |tune|
    title = tune.css('div.info-header h3 a').text
    link  = tune.css('div.actionbar div.actions div.primary a.download')
    next if link.empty?
    urls[title] = "http://soundcloud.com" + link.attr('href')
    print "."
  end
  num += 1
end until tunes.empty?
puts

urls.each do |key,value|
  path = "downloads/#{username}"
  FileUtils.mkdir_p path
  filename = "#{path}/#{key}.mp3"

  unless File.exist?(filename)
    puts "Downloading #{key}"
    downloader.get(value).save(filename)
  else
    puts "Skipped file (already exists)"
  end
end
