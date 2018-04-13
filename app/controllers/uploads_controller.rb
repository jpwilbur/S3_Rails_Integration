class UploadsController < ApplicationController
  def new
  end

  def create
    # Make an object in your bucket for your upload
    obj = S3_BUCKET.bucket(ENV['S3_BUCKET']).object(params[:file].original_filename)

    upload_status = obj.upload_file(
      File.expand_path(params[:file].tempfile),
      {acl: 'public-read'}
    )

    File.delete(params[:file].tempfile)

    # Create an object for the upload
    @upload = Upload.new(
    		url: obj.public_url,
		name: obj.key
    	)

    # Save the upload
    if @upload.save
      redirect_to uploads_path, success: 'File successfully uploaded'
    else
      flash.now[:notice] = 'There was an error'
      render :new
    end
  end

  def index
  
    @uploads = Upload.all

  end
end
