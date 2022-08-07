# frozen_string_literal: true

# refactor to FileDownloader?
module Services
  class VideoParser < ScraperService

    def initialize(video_viewer_url:)
      @video_viewer_url = video_viewer_url
    end

    def call
      local_viewer_file = ENV['LOCAL_VIDEO_VIEWER_SAMPLE_FILE'] || false

      if local_viewer_file
        puts "✅ Using local viewer file for development ONLY"

        html = File.open(local_viewer_file)

      else
        puts "✅ Using live viewer URL"

        uri = URI.parse("#{ENV["CITY_PORTAL_URL"]}#{@video_viewer_url}")
        @video_viewer_url and puts "✅ video_viewer_url: #{uri}"
        response = Net::HTTP.get_response(uri)

        html = response.body
      end

      doc = Nokogiri::HTML(html)

      video_script = doc.search("script")[20].text
      # puts video_script
      video_json = video_script.sub("SetupJWPlayer\(eval\(\'", "").sub("\'\),\'True\',\'True\'\)\;", "")
      video_object = JSON.parse(video_json)
      # video_object and puts "video_object: #{video_object}"
      video_file_url_hi = video_object[0]["file"]
      # video_file_url_hi and puts "video_file_url_hi: #{video_file_url_hi}"

      return video_file_url_hi
    end
  end
end