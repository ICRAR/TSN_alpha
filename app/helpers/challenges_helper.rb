module ChallengesHelper
  def current_users_challenger(challenge,profile)
    challenger = nil
    case challenge.challenger_type.downcase
      when 'alliance'
        challenger = challenge.challengers.where{entity_id == my{profile.alliance_id}}.first
      when 'profile'
        challenger = challenge.challengers.where{entity_id == my{profile.id}}.first
    end
    return challenger
  end
  def challenge_states(current)
    options_for_select([
                           ['All',nil],
                           ['Upcoming','upcoming'],
                           ['Running','running'],
                           ['Finished','finished'],
                       ],current)
  end
  def display_join_button(challenge, profile)
    case challenge.challenger_type.downcase
      when 'alliance'
        #check if their alliance is already in the challenge
        return 'Congratulations your alliance is participating in this challenge.' if challenge.challengers.where{entity_id == my{profile.alliance_id}}.exists?
        return '' unless challenge.joinable?(challenge.invite_code)
        #check if current user is a alliance leader
        return 'You must be the leader of an Alliance to join this challenge.' if profile.alliance_leader_id.nil? || profile.alliance_leader_id == 0
      when 'profile'
        #check if current user is already in the challenge
        return 'Congratulations, you are participating in this challenge.' if challenge.challengers.where{entity_id == my{profile.id}}.exists?
        return '' unless challenge.joinable?(challenge.invite_code)
    end
    if challenge.joinable?(params[:invite_code])
      return link_to('Sign up for this challenge', join_challenge_path(challenge, {invite_code: params[:invite_code]}), class: 'btn btn-success')
    else
      return invite_code_form
    end
  end
  def invite_code_form
    form_tag('', method: :get) do
      placeholder = 'Enter invite Code'
      placeholder = 'Sorry wrong code' unless params[:invite_code].nil?
      label_tag('invite_code') +
      text_field_tag('invite_code', '', placeholder: placeholder) +
      submit_tag('Check code')
    end
  end
end