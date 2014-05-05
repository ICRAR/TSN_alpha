module ChallengersHelper
  include ChallengesHelper
  def score_data(challengers)
    data = []
    challengers.each do |c|
      data << c.score_metric_json(c.name)
    end
    data
  end
  def rank_data(challengers)
    data = []
    challengers.each do |c|
      data << c.rank_metric_json(c.name)
    end
    data
  end

  def number_of_places(challengers, rank)
    challengers.all.count{|c| c.finished? && c.rank == rank}
  end
end
