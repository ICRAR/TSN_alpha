module ProfilesHelper
  def credit_location(profile)
    gsi = profile.general_stats_item
    bonuses = gsi.bonus_credits
    pogs = gsi.boinc_stats_item
    nereus =gsi.nereus_stats_item

    out = []
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
    out << "<p>(Please note that it may take a couple of hours for the total credit value to update)</p>"
    "<dl class=\"dl-horizontal\">#{out.join("\n")}</dl>".html_safe
  end
end
