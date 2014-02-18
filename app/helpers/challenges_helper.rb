module ChallengesHelper
  def challenge_states(current)
    options_for_select([
                           ['All',nil],
                           ['Upcoming','upcoming'],
                           ['Running','running'],
                           ['Finished','finished'],
                       ],current)
  end
end