if false
Paperclip::Attachment.default_options.merge!(
    :storage => :s3,
    :s3_credentials => {
        :bucket => APP_CONFIG['AWS_BUCKET'],
        :access_key_id => APP_CONFIG['AWS_ACCESS_KEY_ID'],
        :secret_access_key => APP_CONFIG['AWS_SECRET_ACCESS_KEY'],
        #:s3_host_name => 'tsn-test-public.s3.amazonaws.com'
    },
    :url => ':s3_domain_url',
    :path => '/:class/:attachment/:id_partition/:style/:filename',
)
end

Paperclip.interpolates(:timestamp) do |attachment, style|
  attachment.instance_read(:updated_at).to_i
end