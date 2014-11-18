class GalaxyMosaicJob < Delayed::BaseScheduledJob
  run_every 7.days

  def perform
    #create a new mosaic
    mosaic = GalaxyMosaic.new_with_defaults
    mosaic.save
    #create the image
    mosaic.build_image
    #notify users
    mosaic.display = true
    mosaic.save
    mosaic.notify_users

  end
end