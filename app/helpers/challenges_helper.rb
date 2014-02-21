module ChallengesHelper
  def challenge_states(current)
    options_for_select([
                           ['All',nil],
                           ['Upcoming','upcoming'],
                           ['Running','running'],
                           ['Finished','finished'],
                       ],current)
  end
  def display_join_button?(challenge, profile)
    return false unless challenge.joinable?
    case challenge.challenger_type.downcase
      when 'alliance'
        #check if current user is a alliance leader
        return false if profile.alliance_leader_id.nil? || profile.alliance_leader_id == 0
        #check if their alliance is already in the challenge
        return false if challenge.challengers.where{entity_id == my{profile.alliance_leader_id}}.exists?
        return true
      when 'profile'
        #check if current user is already in the challenge
        return false if challenge.challengers.where{entity_id == my{profile.id}}.exists?
        return true
    end
  end
end