class Docmosis
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :template, :output_name, :data, :email, :email_subject, :email_body

  validates_presence_of :template, :output_name, :data

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end

  end

  def persisted?
    false
  end

  def email_pdf

    return false if email.nil?
    if !email.nil?
      email_body ||= "Please find your attached report\n \n Regards\n theSkyNet Team"
      email_subject ||= "your report from theSkyNet"
    end
    RestClient.post(render_url,
                    {
                        'accessKey' => access_key,
                        'templateName' => template,
                        'outputName' => output_name,
                        'storeTo' => "mailto:#{email}",
                        'mailSubject' => email_subject,
                        'mailBodyHtml' => email_body,
                        'data' => data
                    }.to_json, :content_type => :json) {|response, request, result, &block|
      case response.code
        when 200
          return true
        else
          # 4XX errors - client errors - something needs to be corrected in the request
          # 5XX errors - server side errors - possibly worth a retry

          # show error response (details)
          puts "Error response:\n\n#{response.code} #{response}\n\n"
          return false
      end
    }
  end

  def get_pdf
    RestClient.post(render_url,
                    {
                        'accessKey' => access_key,
                        'templateName' => template,
                        'outputName' => output_name,
                        'data' => data
                    }.to_json, :content_type => :json) {|response, request, result, &block|
      case response.code
        when 200
          response.to_s
        else
          # 4XX errors - client errors - something needs to be corrected in the request
          # 5XX errors - server side errors - possibly worth a retry

          # show error response (details)
          puts "Error response:\n\n#{response.code} #{response}\n\n"
          response.return!(request, result, &block)
      end
    }
  end

  private
  def access_key
    APP_CONFIG['docmosis_access_key']
  end
  def render_url
    APP_CONFIG['docmosis_render_url']
  end
end