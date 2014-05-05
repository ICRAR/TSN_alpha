class StatsExternalFileJob < Delayed::BaseScheduledJob
  run_every 3.hours
  def perform
    file_name = 'profile_stats'
    #load profiles
    profiles =     @profiles = Profile.for_external_stats
    #Render xml and json
    xml = Rabl::Renderer.xml(profiles, 'misc_jobs/stats/profiles', :view_path => 'app/views')
    json = Rabl::Renderer.json(profiles, 'misc_jobs/stats/profiles', :view_path => 'app/views')

    #write out to temp files
    file_xml = Rails.root.join('tmp', file_name + '.xml.gz')
    Zlib::GzipWriter.open(file_xml) do |gz|
      gz.write xml
    end

    file_json = Rails.root.join('tmp', file_name + '.json.gz')
    Zlib::GzipWriter.open(file_json) do |gz|
      gz.write '{ "profiles" : ' + json +'}'
    end



    #upload to S3
    s3 = AWS::S3.new(
        access_key_id:  APP_CONFIG['AWS_ACCESS_KEY_ID'],
        secret_access_key:  APP_CONFIG['AWS_SECRET_ACCESS_KEY']
    )
    bucket = s3.buckets[APP_CONFIG['AWS_BUCKET']]
    obj = bucket.objects[file_name + '.json.gz']
    obj.write(Pathname.new(file_json))
    obj = bucket.objects[file_name + '.xml.gz']
    obj.write(Pathname.new(file_xml))
  end
end