require 'json'
require 'rest-client'

class FetchJSON
 
  def self.initialize(token = nil)
    @secret_token = token
  end

  def self.air_quality(city)
    unless @secret_token.nil?
      RestClient.get 'https://api.waqi.info/feed/shanghai/?token=demo'
    end 
  end

  def self.tester
    puts "here I am"
  end
end

