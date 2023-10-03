# frozen_string_literal: true

require 'json'
require 'rest-client'

module AleAir
  # Fetches JSON from Waqi API
  class FetchJSON
    attr_writer :secret_token
    attr_reader :status, :message, :time_measured, :location, :quality, :danger_level, :descriptive_text

    def initialize(secret_token = '')
      @secret_token = secret_token
    end

    def air_quality(city = '')
      return if @secret_token.nil?

      response = RestClient.get("https://api.waqi.info/search/?keyword=#{cleaned(city)}&token=#{@secret_token}")
      document = JSON.parse(response.body)

      get_info(document)
    rescue RestClient::ExceptionWithResponse => e
      @message = e.response&.body || 'Unknown Error'
      false
    end

    private

    def cleaned(chars = '')
      CGI.escape(chars.downcase.strip)
    end

    def get_info(document)
      if document['status'] == 'ok' && document['data'].any?
        air = document['data'].first
        aqi = air['aqi']

        return false unless check_aqi(aqi)

        information_message(aqi, air)
      else
        no_data_available_message(document)
      end
    end

    def check_aqi(aqi)
      return true if integer?(aqi)

      @status = 'error'
      @message = 'Invalid Air Quality Value'
      false
    end

    def information_message(aqi, air)
      @status = 'ok'
      @message = 'Air Quality'
      @quality = aqi
      @time_measured = "#{air.dig('time', 'stime')} #{air.dig('time', 'tz')}"
      @location = air.dig('station', 'name')
      @danger_level = danger_lev(aqi)
      @descriptive_text = "Air quality: #{aqi} AQI #{danger_lev(aqi)} @ #{air.dig('station',
                                                                                  'name')} #{@time_measured}"
      true
    end

    def no_data_available_message(document)
      @status = 'error'
      @message = case document['data']
                 when String then document['data']
                 else 'No Data Available'
                 end
      false
    end

    def danger_lev(aqi)
      case aqi.to_i
      when 0..50 then 'Good'
      when 51..100 then 'Moderate'
      when 101..150 then 'Unhealthy for Sensitive Groups'
      when 151..200 then 'Unhealthy'
      when 201..300 then 'Very Unhealthy'
      else 'Hazardous'
      end
    end

    def integer?(aqi)
      Integer(aqi)
    rescue ArgumentError
      false
    else
      true
    end
  end
end
