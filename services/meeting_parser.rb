# frozen_string_literal: true

module Services
  class MeetingParser < ScraperService
    
    def initialize(meeting:)
      @meeting = meeting
    end

    def call
      datetime = @meeting.css('div.RowLink a').text
      meeting_body = @meeting.css('div.RowBottom .RowDetails').text

      is_cancelled = @meeting.css('span.MeetingCancelled').empty? ? false : true
      
      agenda, agenda_packet, minutes, journal, video = ""

      if !is_cancelled
        meeting_links = @meeting.css('div.MeetingLinks a')

        agenda = meeting_links[0].attributes["href"].value
        agenda_packet = meeting_links[1].attributes["href"].value
        minutes = meeting_links[2].attributes["href"].value
        journal = meeting_links[3].attributes["href"].value

        # TODO: add a check around video downloading

        video_onclick = meeting_links[4].attributes["onclick"]
        video = video_onclick ? parse_video_link(video_onclick) : nil
        # video and puts "video: #{video}"
        video_file = Services::VideoParser.call(video_viewer_url: video)
        # video_file and puts "video_file: #{video_file}"

        video_file_name = "#{CGI.escape(datetime)}.mpeg4"
        video_file_name and puts "video_file_name: #{video_file_name}"
        Services::VideoDownloader.call(file_url: video_file, file_name: video_file_name)
      end

      # TODO: conditionally include the video_file?
      # { datetime: datetime, meeting_body: meeting_body, agenda: agenda, agenda_packet: agenda_packet, minutes: minutes, journal: journal, video: video, video_file: video_file }
      { datetime: datetime, meeting_body: meeting_body, agenda: agenda, agenda_packet: agenda_packet, minutes: minutes, journal: journal, video: video }
    end

    private

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
  end
end