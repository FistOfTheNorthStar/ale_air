require 'json'
require 'rest-client'
require 'yaml'

describe 'FetchJSON' do
  
  describe '#danger_lev' do
    
    let(:fetch_json) {AleAir::FetchJSON.new}   
    
    it "returns danger level of air string according to aqi" do
      levels = [0,51,101,151,201,301]
      danger_array = ["Good", "Moderate", "Unhealthy for Sensitive Groups", "Unhealthy", "Very Unhealthy", "Hazardous"]
      danger_array_append = []
      levels.each do |level|
        danger_array_append << fetch_json.send(:danger_lev, level)
      end
      expect(danger_array).to match_array(danger_array_append)
    end
  end

  describe '#is_int' do
    fetch_json = AleAir::FetchJSON.new
    it "returns false on a string without value to convert" do
      temp_val = "this is just a string"
      expect(fetch_json.send(:is_int, temp_val)).to be false
    end

    it "returns int from a string" do
      expect(fetch_json.send(:is_int, "100")).to be true
    end
  end

  describe "#get_info" do

    before(:example) do
      @fetch_json = AleAir::FetchJSON.new
    end

    it 'send correctly formatted hash with status ok' do
      hash_correct = {"status" => "ok", "message" => "all good test", "data" => [{"aqi" => "100", "time" => {"stime" => "19:00", "tz" => "+2"}, "station" => {"name" => "test place"}}]}
      correct_array = ["ok", "Air Quality", "Moderate", "100", "19:00 +2", "test place", "Air quality: 100 AQI Moderate @ test place 19:00 +2"]
      got_back = @fetch_json.send(:get_info, hash_correct)
      back_array = [@fetch_json.status, @fetch_json.message, @fetch_json.quality, @fetch_json.location, @fetch_json.danger_level, @fetch_json.time_measured, @fetch_json.irc_string]
      expect(got_back).to be true
      expect(correct_array).to match_array(back_array)
    end

    it 'send nil hash should receive false' do
      hash_correct = nil
      expect(@fetch_json.send(:get_info, hash_correct)).to be false

    end

    it 'send error receive false' do
      hash_correct = {"status" => "error"}
      expect(@fetch_json.send(:get_info, hash_correct)).to be false
    end

  end

  describe "#air_quality" do

    it 'returns false with nil key with correct city' do
      fetch_json = AleAir::FetchJSON.new    
      expect(fetch_json.air_quality('Helsinki')).to be false
      sleep(5)
    end

    it 'returns false with incorrect key with correct city' do
      fetch_json = AleAir::FetchJSON.new('ABCDSLJ')
      expect(fetch_json.air_quality('Helsinki')).to be false
      sleep(5)
    end

    it 'returns false with nonexisting name correct key' do
      fetch_json = AleAir::FetchJSON.new(api_key['api_key'])
      expect(fetch_json.air_quality('lkjlkjlkjlkjlkj')).to be false
      sleep(5)
    end

    it 'returns true with correct place name correct key' do
      fetch_json = AleAir::FetchJSON.new(api_key['api_key'])
      expect(fetch_json.air_quality('Helsinki')).to be true
    end
  end

  protected
  def api_key
    @config = YAML.load_file("./config/key.yml")
  end

end
