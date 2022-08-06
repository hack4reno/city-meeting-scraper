require 'aws-sdk-s3'

module Services
  class S3Uploader
    def initialize(local_file:, key:)
      @local_file = local_file
      @key = key
      @client = Aws::S3::Client.new(
        region: ENV['AWS_REGION'],
        credentials: aws_credentials
      )
    end

    # TODO: Iterate on key to support folders and different filenames / types
    def upload
      if key_exists_in_s3?(@key)
        puts "✅ File #{@local_file} already exists in S3 as #{@key}."
        return
      end
      puts "⬆️  Uploading #{@local_file} to S3 as #{@key}..."
      s3 = Aws::S3::Resource.new
      bucket = s3.bucket(ENV['AWS_BUCKET_NAME'])
      object = bucket.object(@key)
      object.upload_file(@local_file)
      puts "✅ Upload done for #{@key}"

      # TODO: add error handling
      # puts "❌ Failed to upload #{@local_file} to S3 as #{@key}"
    end

    private

    def key_exists_in_s3?(key)
      s3 = Aws::S3::Resource.new
      bucket = s3.bucket(ENV['AWS_BUCKET_NAME'])
      bucket.object(key).exists?
    end

    def aws_credentials
      Aws::Credentials.new(
        ENV['AWS_ACCESS_KEY_ID'],
        ENV['AWS_SECRET_ACCESS_KEY']
      )
    end
  end
end