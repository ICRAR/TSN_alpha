module ProfilesHelper
  def credit_location(profile)
    gsi = profile.general_stats_item
    bonuses = gsi.bonus_credits
    pogs = gsi.boinc_stats_item
    nereus =gsi.nereus_stats_item

    out = []
=begin
    bonuses.each do |b|
      reason = "<abbr title=\"#{b.reason}\">Bonus Credit</abbr>"
      out << "#{reason} (#{number_with_delimiter(b.amount)} cr)"
    end
    out << "POGS (#{number_with_delimiter(pogs.credit)} cr)" if !pogs.try(:credit).nil? & (pogs.try(:credit) > 0)
    out << "SourceFinder (#{number_with_delimiter(nereus.credit)} cr)" if !nereus.try(:credit).nil? & (nereus.try(:credit) > 0)

    "&#160&#160&#160#{out.join("<br /> + ")}<br /> = total (#{number_with_delimiter(gsi.total_credit)} cr)".html_safe
=end
    first = "&nbsp;&nbsp;&nbsp;"
    bonuses.each do |b|
      reason = "<abbr title=\"#{b.reason}\">Bonus Credit</abbr>"
      out << "<dt>#{reason}</dt> <dd>#{first}#{number_with_delimiter(b.amount)} cr</dd>"
      first = " + "
    end
    if !pogs.try(:credit).nil? && (pogs.credit  > 0)
      out << "<dt>POGS</dt> <dd>#{first}#{number_with_delimiter(pogs.credit)} cr</dd>"
      first = " + "
    end
    if !nereus.try(:credit).nil? && (nereus.credit > 0)
      out << "<dt>SourceFinder</dt> <dd>#{first}#{number_with_delimiter(nereus.credit)} cr</dd>"
      first = " + "
    end
    out << "<dt>Total</dt> <dd> = #{number_with_delimiter(gsi.total_credit)} cr </dd>"
    "<dl class=\"dl-horizontal\">#{out.join()}</dl>".html_safe
  end
end
