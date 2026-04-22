# frozen_string_literal: true

require 'cgi'
require 'json'
require 'net/http'
require 'uri'

module AleAir
  # Fetches air-quality data from the WAQI (World Air Quality Index) API.
  class FetchJSON
    DEFAULT_BASE_URL = 'https://api.waqi.info'
    DEFAULT_OPEN_TIMEOUT = 5
    DEFAULT_READ_TIMEOUT = 10

    attr_reader :status, :message, :time_measured, :location, :quality,
                :danger_level, :descriptive_text

    def initialize(secret_token = nil, base_url: DEFAULT_BASE_URL,
                   open_timeout: DEFAULT_OPEN_TIMEOUT, read_timeout: DEFAULT_READ_TIMEOUT)
      @secret_token = secret_token.to_s
      @base_url = base_url
      @open_timeout = open_timeout
      @read_timeout = read_timeout
    end

    def air_quality(city = '')
      return error('Missing API token') if @secret_token.empty?

      document = get_json("/search/?keyword=#{cleaned(city)}&token=#{@secret_token}")
      get_info(document)
    rescue NetworkError => e
      error("Network error: #{e.message}")
    rescue JSON::ParserError => e
      error("Invalid JSON response: #{e.message}")
    end

    private

    def get_json(path)
      uri = URI.join(@base_url, path)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https',
                                                     open_timeout: @open_timeout,
                                                     read_timeout: @read_timeout) do |http|
        http.get(uri.request_uri)
      end
      JSON.parse(response.body.to_s)
    rescue SocketError, Timeout::Error, Errno::ECONNREFUSED, OpenSSL::SSL::SSLError => e
      raise NetworkError, e.message
    end

    def cleaned(chars = '')
      CGI.escape(chars.to_s.downcase.strip)
    end

    def get_info(document)
      return no_data_available_message(document) unless document.is_a?(Hash)
      return no_data_available_message(document) unless document['status'] == 'ok'
      return no_data_available_message(document) unless document['data'].is_a?(Array) && document['data'].any?

      air = document['data'].first
      aqi = air['aqi']
      return error('Invalid Air Quality Value') unless integer?(aqi)

      information_message(aqi, air)
    end

    def information_message(aqi, air)
      station_name = air.dig('station', 'name')
      @status = 'ok'
      @message = 'Air Quality'
      @quality = aqi
      @time_measured = "#{air.dig('time', 'stime')} #{air.dig('time', 'tz')}"
      @location = station_name
      @danger_level = danger_lev(aqi)
      @descriptive_text = "Air quality: #{aqi} AQI #{@danger_level} @ #{station_name} #{@time_measured}"
      true
    end

    def no_data_available_message(document)
      detail = document.is_a?(Hash) ? document['data'] : nil
      error(detail.is_a?(String) ? detail : 'No Data Available')
    end

    def error(message)
      @status = 'error'
      @message = message
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
      true
    rescue ArgumentError, TypeError
      false
    end
  end
end
