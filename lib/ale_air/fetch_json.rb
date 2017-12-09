require 'json'
require 'rest-client'

module AleAir
  class FetchJSON
    attr_writer :secret_token
    attr_reader :status, :message, :time_measured, :location, :quality, :danger_level

    def initialize(token = nil)
      @secret_token = token
    end

    def air_quality(city = nil)
      unless @secret_token.nil?
        document = JSON.parse(RestClient.get 'https://api.waqi.info/search/?keyword=' + cleaned(city) + '&token=' + @secret_token)
        get_info(document)
      end 
    end

    private
    def cleaned(chars = "")
      URI.encode(chars.downcase.strip)
    end

    def get_info(document = nil)
      unless document.nil?
        if document["status"] == "ok"
	  if document["data"].length > 0
            document["data"].each do |air|
	      if !air["aqi"].nil? || !air["aqi"].empty?
		unless is_int(air["aqi"])
		  @status = "error"
	          @message = "Invalid Airquality Value"
		  return true
	        end	  
		@status = "ok"
		@message = "Air Quality"
		@quality = air["aqi"]
		@time_measured = air["time"]["stime"] + ' ' + air["time"]["tz"]
		@location = air["station"]["name"]
		@danger_level = danger_lev(air["aqi"].to_i)
	        return true
	      else
		@status = "error"
		@message = "No Data Available"
              end
            end
	  else
	    @status = "error"
	    @message = "No Stations Found"
	  end
	else
          @status = "error"
          if document["message"]
	    @message = document["message"]
	  else
            @message = "Unknown Error"
          end
	end	  
      end
      return false
    end

    def danger_lev(aqi=0)
      case aqi
      when 0..50
        "Good"
      when 51..100
        "Moderate"
      when 101..150
        "Unhealthy for Sensitive Groups"
      when 151..200
	"Unhealthy"
      when 201..300
        "Very Unhealthy"
      else
	"Hazardous"
      end
    end

    def is_int(string)
      Integer(string).is_a?(Integer)
    rescue ArgumentError, TypeError
      false
    end

  end
end
