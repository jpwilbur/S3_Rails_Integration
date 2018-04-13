class Admin::UploadsController < ApplicationController
  def create

    file = S3_BUCKET.bucket(ENV['S3_BUCKET']).object(params[:file].original_filename)

    # uploads file from tmp directory to S3 (file is created as a publicly readable file by default)
    upload_status = file.upload_file(
      File.expand_path(params[:file].tempfile),
      {acl: params[:viewable]}
    )

    File.delete(params[:file].tempfile)

    if !upload_status
      render json: {message: "Upload to AWS Failed"}, status: :internal_server_error and return
    end
  end
end
