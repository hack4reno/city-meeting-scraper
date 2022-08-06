require 'uri'
require 'dotenv/load'
require 'net/http'
require 'byebug'
require 'nokogiri'

class AgendaScraper

  def parse_meeting(meeting)

    datetime = meeting.css('div.RowLink a').text
    meeting_body = meeting.css('div.RowBottom .RowDetails').text

    is_cancelled = meeting.css('span.MeetingCancelled').empty? ? false : true

    agenda, agenda_packet, minutes, journal, video = ""

    if !is_cancelled
      meeting_links = meeting.css('div.MeetingLinks a')

      agenda = meeting_links[0].attributes["href"].value
      agenda_packet = meeting_links[1].attributes["href"].value
      minutes = meeting_links[2].attributes["href"].value
      journal = meeting_links[3].attributes["href"].value
      video = meeting_links[4].attributes["href"].value
    end

    # date
    # time
    # location
    # meeting_body
    # is_cancelled
    # agenda
    # agenda_packet
    # minutes
    # journal
    # agenda_table
    # agenda_item_timestamp
    # agenda_items
    # meeting_attachments

    { datetime: datetime, meeting_body: meeting_body, agenda: agenda, agenda_packet: agenda_packet, minutes: minutes, journal: journal, video: video }
  end

  def download_meeting(meeting)
    # download the meeting
    # download the agenda
    # download the agenda packet
    # download the minutes
    # download the journal
    # download the video
    puts meeting

    # follow each link and download the file
    # how can we get the video?

    # save these to S3 by meeting
  end

  def initialize()
    local_file = ENV['LOCAL_PORTAL_FILE'] || false

    if local_file
      puts "Using local file"

      file_contents = File.open(local_file)

      process(file_contents)
    else
      puts "Using live URL"

      uri = URI.parse(ENV["CITY_PORTAL_URL"])
      response = Net::HTTP.get_response(uri)

      process(response.body)
    end
  end

  def process(html)
    doc = Nokogiri::HTML(html)

    meeting_rows = doc.css('.Row.MeetingRow')

    test_meeting = meeting_rows.first

    meeting_rows.each do |meeting_row|
      meeting = parse_meeting(meeting_row)
      download_meeting(meeting)
    end
  end
end

AgendaScraper.new.initialize
