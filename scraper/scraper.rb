require 'nokogiri'
require 'httparty'
require 'byebug'
require 'csv'


def scraper
	url = "https://www.work.ua/jobs-chernivtsi_cv-it/?advs=1&page=1"
	unparsed_page = HTTParty.get(url)
	parsed_page = Nokogiri::HTML(unparsed_page)
	jobs= Array.new
	job_listings = parsed_page.xpath('//div[@class="card card-hover card-visited wordwrap job-link"]')
	page = 1
	per_page = job_listings.count
	total = parsed_page.xpath('//div[@class="add-top"]').text.split(' ')[0].to_i
	last_page = (total.to_f / per_page.to_f).round
	while page <= last_page
		pagination_url = "https://www.work.ua/jobs-chernivtsi_cv-it/?advs=1&page=#{page}"
		puts pagination_url
		puts "Page: #{page}"
		puts ''
		pagination_unparsed_page = HTTParty.get(pagination_url)
		pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
		pagination_job_listings = pagination_parsed_page.xpath('//div[@class="card card-hover card-visited wordwrap job-link"]')
		pagination_job_listings.each do |job_listing|
			job = {
				vacancy: job_listing.xpath('./h2/a').text,
				salary: job_listing.xpath('./div/b').text,
				company: job_listing.xpath('./div[@class="add-top-xs"]/span/b').text
			}
			jobs << job
			open('C:\Ruby\scraper\data', 'a') { |f| 
    			f.puts job
  			}
  			open('C:\Ruby\scraper\data.json', 'a') { |f| 
    			f.puts job
  			}			
			puts "Added #{job[:vacancy]}"
			puts ""
		end
		page +=1
	end
	byebug
end
scraper
