# frozen_string_literal: true

# refactor to FileDownloader?
module Services
  class VideoDownloader < ScraperService

    def initialize(file_url:, file_name:)
      @file_url = file_url
      @file_name = file_name
    end

    def call
      URI.open("#{@file_name}", 'wb') do |file|
        file << URI.open(@file_url).read
      end
    end
  end
end