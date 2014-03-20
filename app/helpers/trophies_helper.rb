module TrophiesHelper
  def display_trophy_suffix(trophy,trophy_ids)
    return (!(trophy.credits.nil? || trophy.credits == 0) || ["time_active"].include?(trophy.set_type))
  end
  def format_credit(trophy,trophy_ids)
    return nil unless display_trophy_suffix(trophy,trophy_ids)
    case trophy.set_type
      when 'leader_board_position_active'
        trophy_dec = "Rank"
      when "RAC_active"
        trophy_dec = "RAC"
      when "time_active"
        trophy_dec = "Days"
      when 'galaxy_count_active'
        trophy_dec = "Galaxies"
      else
        trophy_dec = "cr"
    end
    "#{number_with_delimiter trophy.show_credits(trophy_ids)} #{trophy_dec}"
  end

  def format_heading(trophy,trophy_ids)
    suffix = format_credit(trophy,trophy_ids)
    if suffix.nil?
      trophy.title
    else
      "#{trophy.title} (#{suffix})"
    end
  end

  def format_desc(trophy,trophy_ids)
    return nil unless display_trophy_suffix(trophy,trophy_ids)
    out = ''
    case @trophy.set_type
      when 'leader_board_position_active'
        out = "(Awarded for being in the top #{number_with_delimiter @trophy.show_credits(@trophy_ids)} people)"
      when 'time_active'
        out = "(Awarded for being a member for at least #{number_with_delimiter @trophy.show_credits(@trophy_ids)} days)"
      when "RAC_active"
        out = "(Awarded for reaching an RAC of #{number_with_delimiter @trophy.show_credits(@trophy_ids)} or higher)"
      when "galaxy_count_active"
        out = "(Awarded for contributing to more than #{number_with_delimiter @trophy.show_credits(@trophy_ids)} galaxies)"
      else
        out = "(Awarded for achieving #{number_with_delimiter @trophy.show_credits(@trophy_ids)} credits)"
    end
    return out
  end

end
