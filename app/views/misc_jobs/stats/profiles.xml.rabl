@profiles
attributes :id, :name, :rank, :credits, :rac
glue :general_stats_item do |g|
  if g.nereus_stats_item != nil
    child :nereus_stats_item => :SourceFinder do |n|
      attributes :nereus_id, :credit, :daily_credit
    end
  end
  if g.boinc_stats_item != nil
    child :boinc_stats_item do
      attributes :boinc_id, :credit, :RAC
    end
  end
end

node(:alliance, :if => lambda { |p| p.alliance_id.nil? }) {nil}
node(:alliance_id, :if => lambda { |p| !p.alliance_id.nil? }) {|p| p.alliance_id}
node(:alliance_url, :if => lambda { |p| !p.alliance_id.nil? }) {|p| Rails.application.routes.url_helpers.alliance_url id: p.alliance_id, host: APP_CONFIG['site_host'], format: :json}


node(:profile_url) {|p| Rails.application.routes.url_helpers.profile_url id: p.id, host: APP_CONFIG['site_host'], format: :json}