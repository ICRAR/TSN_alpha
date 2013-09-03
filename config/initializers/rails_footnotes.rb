if defined?(Footnotes) && Rails.env.development?
  Footnotes.setup do |config|
    config.before do |controller, filter|
      if controller.action_name == 'facebook_channel' #  any conditions
        controller.params[:footnotes] = "false" # disable footnotes
      end
    end
  end

  Footnotes.run! # first of all

  # ... other init code
end
