# Script was developed and worked on Windows.
# OpenURI module was used instead Curb.
require 'byebug'
require 'csv'
require 'nokogiri'
require 'open-uri'

cat_url = ARGV[0] # https://www.petsonic.com/dermatitis-y-problemas-piel-para-perros/
file_name = ARGV[1] # products.csv

unparsed_page = URI.open(cat_url)
parsed_page = Nokogiri::HTML(unparsed_page)
all_product_link = [] # Array for keeping links to products

parsed_page.xpath(".//*[@id='product_list']/li/div/div[2]/div[2]/a/@href").each do |product_link|
  all_product_link << product_link.text
end

CSV.open(file_name, "wb") do |csv_line|
  csv_line << %w[Name Price Image]

  all_product_link.each do |product_url|
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
  end
end