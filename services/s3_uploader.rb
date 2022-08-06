require 'aws-sdk-s3'

module Services
  class S3Uploader
    def initialize
      @client = Aws::S3::Client.new(
        region: ENV['AWS_REGION'],
        credentials: aws_credentials
      )
    end

    def upload
      file_url = "../source-data/2198.pdf"

      s3 = Aws::S3::Resource.new
      bucket = s3.bucket(ENV['AWS_BUCKET_NAME'])
      object = bucket.object("2198.pdf")
      object.upload_file(file_url)
    end

    private

    def exists?(key)
      # TODO: feature to check if key exists in S3 already
      # check if the file is already in the bucket
    end

    def aws_credentials
      Aws::Credentials.new(
        ENV['AWS_ACCESS_KEY_ID'],
        ENV['AWS_SECRET_ACCESS_KEY']
      )
    end
  end
end