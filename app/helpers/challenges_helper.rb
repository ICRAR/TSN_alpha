module ChallengesHelper
  def challenge_states(current)
    options_for_select([
                           ['All',nil],
                           ['Upcoming','upcoming'],
                           ['Running','running'],
                           ['Finished','finished'],
                       ],current)
  end
  def display_join_button(challenge, profile)
    return '' unless challenge.joinable?
    case challenge.challenger_type.downcase
      when 'alliance'
        #check if current user is a alliance leader
        return 'You must be the leader of an Alliance to join this challenge.' if profile.alliance_leader_id.nil? || profile.alliance_leader_id == 0
        #check if their alliance is already in the challenge
        return 'Congratulations your alliance is participating in this challenge.' if challenge.challengers.where{entity_id == my{profile.alliance_leader_id}}.exists?
        return link_to('Sign up for this challenge', join_challenge_path(challenge), class: 'btn btn-success')
      when 'profile'
        #check if current user is already in the challenge
        return 'Congratulations you are participating in this challenge.' if challenge.challengers.where{entity_id == my{profile.id}}.exists?
        return link_to('Sign up for this challenge', join_challenge_path(challenge), class: 'btn btn-success')
    end
  end
end