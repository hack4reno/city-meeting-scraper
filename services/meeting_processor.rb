# frozen_string_literal: true

module Services
  class MeetingProcessor < ScraperService
    def initialize(meeting:, s3_enabled:)
      @meeting = meeting
      @s3_enabled = s3_enabled
    end

    def call
      # puts @meeting
      # download the linked meeting page as html
      # download the meeting files locally
      # download the meeting video if available
      # upload each item to S3
      # delete the local meetingi tems
    end

    private

    def upload_file
      return unless @s3_enabled
      # TODO: make this dynamic based on the downloaded file and meeting id, filename and/or timestamp
      Services::S3Uploader(local_file: './source-data/2198.pdf', key: '2198.pdf').call
    end
  end
end