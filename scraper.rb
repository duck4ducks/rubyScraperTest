require 'byebug'
require 'csv'
require 'nokogiri'
require 'open-uri'

cat_url = "https://www.petsonic.com/dermatitis-y-problemas-piel-para-perros/"
file_name = "products.csv"

unparsed_page = URI.open(cat_url)
parsed_page = Nokogiri::HTML(unparsed_page)
products_list = parsed_page.xpath(".//*[@id='product_list']/li")

CSV.open(file_name, "wb") do |csv_line|
  csv_line << %w[Name Price Image]

  products_list.each do |product_card|
    product = {
      title: product_card.xpath('.//div[@itemtype="http://schema.org/Product"]/meta[@itemprop="name"]/@content').text,
      price: product_card.xpath('.//meta[@itemprop="price"]/@content').text,
      img_path: product_card.xpath('.//link[@itemprop="image"]/@href').text
    }
    product_info = [product[:title], product[:price], product[:img_path]]
    csv_line << product_info
  end
end