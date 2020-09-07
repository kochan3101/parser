require 'curb'
require 'nokogiri'
require 'csv'

$XPATH_ITEM = '//div[@class="product-container"]/div/div/a/@href'
$XPATH_NAME = '//h1[contains(@class ,"product_main_name")]'
$XPATH_WEIGHT = '//span[contains(@class, "radio_label")]'
$XPATH_PRICE = '//span[contains(@class, "price_comb")]'
$XPATH_PIC = '//img[@id="bigpic"]/@src'

class Category_Pars
    def initialize(url, fil_name)
      @url = url
      @pagination_url = []
      @file_name = fil_name
      puts 'initialization begins'

    end

    def pars
      start_time = Time.now
      puts 'data collection for parsing'
      html = Curl.get(@url) # I take the urls of a pages with a given category
      doc = Nokogiri::HTML(html.body)
      links = doc.xpath($XPATH_ITEM)
      if links.length > 1 # checking url for pagination

      for link in links
        @pagination_url.push(link)
         end
        else
         @pagination_url.push(links)
      end
      puts 'open the csv file'
      CSV.open(@file_name, 'w') do |csv| # I open the file for writing
        csv << %w[Name Price Image]
      puts "I'm starting to parse"
      @pagination_url.each_with_index {  |pag_url,j|

          pag_html = Curl.get(pag_url)
          pag_doc = Nokogiri::HTML(pag_html.body)
      weights = pag_doc.xpath($XPATH_WEIGHT).to_a # collecting information on products
      pic = pag_doc.xpath($XPATH_PIC).to_s
      name = pag_doc.xpath($XPATH_NAME).first.content
      prices = pag_doc.xpath($XPATH_PRICE)

      weights.each_with_index {  |weight, i| # writing to file
      name_str = "#{name} - " + weight
        csv << [name_str,
                prices[i].text,
            pic]
      }
          puts "completed #{j} of #{@pagination_url.length}"
      }
      end
      puts "Time of parsing – #{Time.now - start_time} seconds." # find out how long it takes to parse
    end
    end
url_to_parse = ARGV[0]
file = ARGV[1]
items  = Category_Pars.new(url_to_parse, file)
items.pars
