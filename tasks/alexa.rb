##
# Adapted from gist: https://gist.github.com/zerothabhishek/3015666
# Orginal author: zerothabhishek
##

require 'nokogiri'
require 'open-uri'
require 'csv'

namespace :alexa do
  desc 'Scrapes the Alexa Top 500 and updates spec/data/alexa.csv'
  task :scrape do
    CSV.open("spec/data/alexa.csv","w") do |csv|
      (0..19).each do |i|
        url = "http://www.alexa.com/topsites/global;#{i} "
        doc = Nokogiri::HTML(open(url))

        doc.css(".site-listing").each do |li|
          begin
            site_name = li.css(".desc-container .desc-paragraph a")[0].content
            site_rank = li.css(".count")[0].content

            csv << [site_rank, site_name]
          rescue
          end
        end
      end
    end
  end
end
