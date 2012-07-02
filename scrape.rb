require 'open-uri'
require 'rubygems'
require 'nokogiri'

page = ARGV[0] || 1

doc = Nokogiri::HTML(open("http://dubstep.net/p/#{page}"))
doc.xpath('//div[@class="action_button_container"]/a').each do |node|
  if node.text =~ /Download/
    title    = node.parent.parent.xpath('h2/a').text
    url      = node.attr('href')
    filename = "#{title}.mp3"

    unless File.exist?(filename)
      puts
      puts "Downloading #{title}"
      puts

      `curl -L #{url} -o "#{filename}"`
    else
      puts "Already downlaoded #{filename}"
    end
  end
end

