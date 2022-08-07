# TODO: can we load all required files using zeitwerk?
require 'aws-sdk-s3'
require 'byebug'
require 'cgi'
require 'dotenv/load'
require 'json'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'uri'
require './services/scraper_service'
require './services/video_parser'
require './services/video_downloader'
require './services/s3_uploader'
require './services/meeting_parser'
require './services/meeting_processor'

class MeetingScraper

  def initialize()
    local_file = ENV['LOCAL_PORTAL_FILE'] || false
    @s3_enabled = s3_enabled?

    if local_file
      puts "✅ Using local file as import source"

      file_contents = File.open(local_file)

      @html_to_parse = file_contents
    else
      puts "✅ Using live URL as import source"

      uri = URI.parse(ENV["CITY_PORTAL_URL"])
      response = Net::HTTP.get_response(uri)

      @html_to_parse = response.body
    end
  end

  def start!
    meetings = fetch_meetings

    meetings.reverse.each do |meeting|
      parsed_meeting = Services::MeetingParser.call(meeting: meeting)
      Services::MeetingProcessor.call(meeting: parsed_meeting, s3_enabled: @s3_enabled)
    end
  end
  
  private

  def fetch_meetings
    doc = Nokogiri::HTML(@html_to_parse)
    meeting_rows = doc.css('.Row.MeetingRow')
  end

  def s3_enabled?
    s3_enabled = ENV['UPLOAD_TO_S3'] == "true" ? true : false
    puts "#{s3_enabled ? '✅' : '🔴'} S3 uploads are #{s3_enabled ? 'enabled' : 'disabled'}."
    return s3_enabled
  end
end

MeetingScraper.new.start!