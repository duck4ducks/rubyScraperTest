# Script was developed and worked on Windows.
# OpenURI module was used instead Curb.
require 'byebug'
require 'csv'
require 'nokogiri'
require 'open-uri'

cat_url = ARGV[0] # 'https://www.petsonic.com/dermatitis-y-problemas-piel-para-perros/'
file_name = ARGV[1] # 'products.csv'

arr_links = [] # Array for keeping links to products
parsed_page = Nokogiri::HTML(URI.open(cat_url))

puts "I started from #{cat_url}"

loop do
  parsed_page.xpath(".//*[@id='product_list']/li/div/div[2]/div[2]/a/@href").each do |product_link|
    arr_links << product_link.text
  end
  next_page = parsed_page.xpath('.//li[@id="pagination_next_bottom"]/a/@href').text
  break if next_page.empty?

  puts "I found next page for this category! #{next_page}"
  parsed_page = Nokogiri::HTML(URI.open("https://www.petsonic.com#{next_page}"))
end

puts "I count #{arr_links.count} product pages!"

CSV.open(file_name, 'wb') do |csv_line|
  csv_line << %w[Name Price Image]

  arr_links.each do |product_url|
    product_page = Nokogiri::HTML(URI.open(product_url))

    product_title = product_page.xpath('.//h1[@class="product_main_name"]').text
    product_img = product_page.xpath('.//img[@id="bigpic"]/@src').text

    product_page.xpath(".//div[@class='attribute_list']//ul/li").each do |variation|
      # Object is created for each variation of product

      product = {
        title: "#{product_title} - #{variation.xpath('.//span[@class="radio_label"]').text}", # following the example
        price: variation.xpath('.//span[@class="price_comb"]').text,
        img_path: product_img
      }

      product_info = [product[:title], product[:price], product[:img_path]]
      csv_line << product_info
    end
    puts "I added prod from #{product_url}"
  end
end
# Time 129.0575935000088s, tested by Benchmark.measure
