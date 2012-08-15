require 'open-uri'
require 'rubygems'
require 'nokogiri'

doc = Nokogiri::HTML(open("http://dubstep.net/"))
doc.xpath('//div[@class="action_button_container"]/a').each do |node|
  if node.text =~ /Download/
    title    = node.parent.parent.xpath('.//h2/a').text
    url      = node.attr('href')
    filename = "#{title}.mp3"

    unless File.exist?("downloads/#{filename}")
      `curl -L #{url} -o 'downloads/#{filename}'`
    else
      puts "#{filename} already downloaded."
    end
  end
end

