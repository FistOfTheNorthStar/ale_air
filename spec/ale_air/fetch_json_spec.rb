# frozen_string_literal: true

RSpec.describe AleAir::FetchJSON do
  let(:token) { 'test-token' }
  let(:base_url) { 'https://api.waqi.info' }

  def stub_search(city, token:, body:, status: 200)
    stub_request(:get, "#{base_url}/search/")
      .with(query: { keyword: city.downcase, token: token })
      .to_return(status: status, body: body.is_a?(String) ? body : body.to_json,
                 headers: { 'Content-Type' => 'application/json' })
  end

  describe '#danger_lev' do
    let(:fetch_json) { described_class.new }

    it 'maps AQI ranges to danger levels' do
      levels = { 0 => 'Good', 51 => 'Moderate', 101 => 'Unhealthy for Sensitive Groups',
                 151 => 'Unhealthy', 201 => 'Very Unhealthy', 301 => 'Hazardous' }
      levels.each do |aqi, expected|
        expect(fetch_json.send(:danger_lev, aqi)).to eq(expected)
      end
    end
  end

  describe '#integer?' do
    let(:fetch_json) { described_class.new }

    it 'returns false for a non-numeric string' do
      expect(fetch_json.send(:integer?, 'this is just a string')).to be false
    end

    it 'returns true for a numeric string' do
      expect(fetch_json.send(:integer?, '100')).to be true
    end

    it 'returns false for nil' do
      expect(fetch_json.send(:integer?, nil)).to be false
    end
  end

  describe '#get_info' do
    let(:fetch_json) { described_class.new }

    it 'populates accessors on a valid ok payload' do
      payload = { 'status' => 'ok',
                  'data' => [{ 'aqi' => '100',
                               'time' => { 'stime' => '19:00', 'tz' => '+2' },
                               'station' => { 'name' => 'test place' } }] }
      expect(fetch_json.send(:get_info, payload)).to be true
      expect(fetch_json.status).to eq('ok')
      expect(fetch_json.message).to eq('Air Quality')
      expect(fetch_json.quality).to eq('100')
      expect(fetch_json.location).to eq('test place')
      expect(fetch_json.time_measured).to eq('19:00 +2')
      expect(fetch_json.danger_level).to eq('Moderate')
      expect(fetch_json.descriptive_text).to eq('Air quality: 100 AQI Moderate @ test place 19:00 +2')
    end

    it 'returns false when payload is not a hash' do
      expect(fetch_json.send(:get_info, '')).to be false
      expect(fetch_json.status).to eq('error')
    end

    it 'returns false when status is error' do
      expect(fetch_json.send(:get_info, { 'status' => 'error', 'data' => 'Invalid key' })).to be false
      expect(fetch_json.message).to eq('Invalid key')
    end

    it 'returns false when aqi is not an integer' do
      payload = { 'status' => 'ok',
                  'data' => [{ 'aqi' => '-', 'time' => {}, 'station' => {} }] }
      expect(fetch_json.send(:get_info, payload)).to be false
      expect(fetch_json.message).to eq('Invalid Air Quality Value')
    end
  end

  describe '#air_quality' do
    it 'returns false when no token is provided' do
      fetch_json = described_class.new
      expect(fetch_json.air_quality('Helsinki')).to be false
      expect(fetch_json.message).to eq('Missing API token')
    end

    it 'returns false when the API rejects the token' do
      stub_search('helsinki', token: 'bad', body: { 'status' => 'error', 'data' => 'Invalid key' })
      fetch_json = described_class.new('bad')
      expect(fetch_json.air_quality('Helsinki')).to be false
      expect(fetch_json.message).to eq('Invalid key')
    end

    it 'returns false when the place name has no results' do
      stub_search('lkjlkjlkjlkjlkj', token: token, body: { 'status' => 'ok', 'data' => [] })
      fetch_json = described_class.new(token)
      expect(fetch_json.air_quality('lkjlkjlkjlkjlkj')).to be false
      expect(fetch_json.message).to eq('No Data Available')
    end

    it 'returns true and populates accessors on a successful lookup' do
      stub_search('helsinki', token: token, body: {
                    'status' => 'ok',
                    'data' => [{ 'aqi' => '42',
                                 'time' => { 'stime' => '12:00', 'tz' => '+2' },
                                 'station' => { 'name' => 'Kallio' } }]
                  })
      fetch_json = described_class.new(token)
      expect(fetch_json.air_quality('Helsinki')).to be true
      expect(fetch_json.status).to eq('ok')
      expect(fetch_json.quality).to eq('42')
      expect(fetch_json.location).to eq('Kallio')
      expect(fetch_json.danger_level).to eq('Good')
    end

    it 'returns false and records the network error on connection failure' do
      stub_request(:get, %r{#{base_url}/search/}).to_timeout
      fetch_json = described_class.new(token)
      expect(fetch_json.air_quality('Helsinki')).to be false
      expect(fetch_json.status).to eq('error')
      expect(fetch_json.message).to start_with('Network error:')
    end

    it 'returns false and records a parser error on invalid JSON' do
      stub_search('helsinki', token: token, body: 'not json at all')
      fetch_json = described_class.new(token)
      expect(fetch_json.air_quality('Helsinki')).to be false
      expect(fetch_json.message).to start_with('Invalid JSON response:')
    end
  end
end
