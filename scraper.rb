require 'uri'
require 'dotenv/load'
require 'net/http'
require 'byebug'
require 'nokogiri'
require 'json'
require 'cgi'
require 'open-uri'


class AgendaScraper

  def parse_video_link(video_viewer_onclick)
    video_viewer_url_1 = video_viewer_onclick&.to_str&.sub("javascript:OpenWindow(\"", "")
    video_viewer_url = video_viewer_url_1&.sub("\"\)\;", "")

    # if video_viewer_url
    #   # video_viewer_url_query = URI.parse(video_viewer_url).query
    #   # video_viewer_url_query_hash = Hash[URI.decode_www_form(video_viewer_url_query)]
    #   # video_id = video_viewer_url_query_hash["MeetingID"]

    #   # return video_id
    # end
  end

  def parse_video_viewer(video_viewer_url)

    local_viewer_file = ENV['LOCAL_VIDEO_VIEWER_SAMPLE_FILE'] || false

    if local_viewer_file
      puts "Using local viewer file for development ONLY"

      html = File.open(local_viewer_file)

    else
      # puts "Using live viewer URL"

      uri = URI.parse("#{ENV["CITY_PORTAL_URL"]}#{video_viewer_url}")
      video_viewer_url and puts "video_viewer_url: #{uri}"
      response = Net::HTTP.get_response(uri)

      html = response.body

    end

    doc = Nokogiri::HTML(html)

    # puts doc

    video_script = doc.search("script")[20].text
    # puts video_script
    video_json = video_script.sub("SetupJWPlayer\(eval\(\'", "").sub("\'\),\'True\',\'True\'\)\;", "")
    video_object = JSON.parse(video_json)
    # video_object and puts "video_object: #{video_object}"
    video_file_url_hi = video_object[0]["file"]
    # video_file_url_hi and puts "video_file_url_hi: #{video_file_url_hi}"

    return video_file_url_hi
  end

  def save_file(file_url, file_name)
    open("#{file_name}", 'wb') do |file|
      file << open(file_url).read
    end
  end

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
      video_onclick = meeting_links[4].attributes["onclick"]
      video = video_onclick ? parse_video_link(video_onclick) : nil
      # video and puts "video: #{video}"
      video_file = parse_video_viewer(video)
      # video_file and puts "video_file: #{video_file}"

      video_file_name = "#{CGI.escape(datetime)}.mpeg4"
      video_file_name and puts "video_file_name: #{video_file_name}"
      video_file and save_file(video_file, video_file_name)
      video_file and exit

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

    { datetime: datetime, meeting_body: meeting_body, agenda: agenda, agenda_packet: agenda_packet, minutes: minutes, journal: journal, video: video, video_file: video_file }
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

  def init()
    local_file = ENV['LOCAL_PORTAL_FILE'] || false

    if local_file
      puts "Using local meeting list file"

      file_contents = File.open(local_file)

      process(file_contents)
    else
      # puts "Using live meeting list URL"

      uri = URI.parse(ENV["CITY_PORTAL_MEETING_LIST_URL"])
      response = Net::HTTP.get_response(uri)

      process(response.body)
    end
  end

  def process(html)
    doc = Nokogiri::HTML(html)

    meeting_rows = doc.css('.Row.MeetingRow')

    test_meeting = meeting_rows.first

    meeting_rows.reverse.each do |meeting_row|
      meeting = parse_meeting(meeting_row)
      download_meeting(meeting)
    end
  end
end

AgendaScraper.new.init
