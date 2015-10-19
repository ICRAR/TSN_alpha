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
  def boinc_computers(boinc_hosts)

    out = []
    out << "<ul>"
    boinc_hosts.each do |host|
      out << "<li>#{host.domain_name.to_s.force_encoding("UTF-8")}</li>"
    end
    out << "</ul>"
    out.join("\n").html_safe
  end

  #sorts the trophies into rows and columns with the most important trophies centered
  def sort_trophies_by_priority(trophies)
    #number of trophies per row
    per_row_small = 16
    per_row_medium = 4
    per_row_large = 1


    rows = []
    per_row = per_row_small + per_row_medium + per_row_large
    num_rows = (trophies.size / per_row.to_f).ceil
    (1..num_rows).each {rows << {:far_left => [],:left => [],:center => [],:right => [],:far_right => []}}
    i = 0
    trophies.each do |trophy|
      #fill center first
      if i < num_rows*per_row_large
        rows[i/per_row_large][:center] << trophy
      #fill left and right rows next
      elsif i < (num_rows*per_row_medium+num_rows*per_row_large)
        j = i - num_rows
        if j.even?
          rows[j/per_row_medium][:left] << trophy
        else
          rows[j/per_row_medium][:right] << trophy
        end
      #fill far left and far right rows next
      elsif i < (num_rows* per_row_small + num_rows*per_row_medium+num_rows)
        j = i - num_rows*per_row_medium - num_rows
        if j.even?
          rows[j/per_row_small][:far_left] << trophy
        else
          rows[j/per_row_small][:far_right] << trophy
        end
      end
      i = i + 1
    end
    rows
  end

  def show_likes(model, display, model_name_method)
    out = ''
    out << "<h3>#{display}</h3> \n"
    out << ""
    m_array = []
    objects = @profile.likeables_relation(model)
    objects.each do |object|
      m_array << link_to(object.send(model_name_method), object)
    end
    out << "<p>#{array_to_paragraph(m_array)}</p>"
    return out.html_safe
  end

end
