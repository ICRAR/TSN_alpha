module ProfilesHelper
  def credit_location(profile)
    gsi = profile.general_stats_item
    bonuses = gsi.bonus_credits
    pogs = gsi.boinc_stats_item
    nereus =gsi.nereus_stats_item

    out = []
    bonuses.each do |b|
      reason = "<abbr title=\"#{b.reason}\">Bonus Credit</abbr>"
      out << "#{reason} (#{b.amount} cr)"
    end
    out << "POGS (#{pogs.credit} cr)" if !pogs.try(:credit).nil? & (pogs.try(:credit) > 0)
    out << "SourceFinder (#{nereus.credit} cr)" if !nereus.try(:credit).nil? & (nereus.try(:credit) > 0)

    "#{out.join(" + ")} = total (#{gsi.total_credit} cr)".html_safe
  end
end
