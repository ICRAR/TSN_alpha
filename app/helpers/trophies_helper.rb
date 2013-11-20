module TrophiesHelper
  def format_credit(trophy,trophy_ids)
    case trophy.set_type
      when "RAC_active"
        trophy_dec = "RAC"
      else
        trophy_dec = "cr"
    end
    "#{number_with_delimiter trophy.show_credits(trophy_ids)} #{trophy_dec}"
  end

  def format_heading(trophy,trophy_ids)
    if trophy.credits.nil? || trophy.credits == 0
      trophy.title
    else
      "#{trophy.title} (#{format_credit(trophy,trophy_ids)})"
    end
  end
end
