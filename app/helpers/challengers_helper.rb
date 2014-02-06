module ChallengersHelper
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
end
