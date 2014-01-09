class AdventJob
  include Delayed::ScheduledJob
  run_every 24.hours
  def perform
    users = User.joins(:profile).where{profile.advent_notify == true}
    users.each do |user|
      UserMailer.advent_notify(user).deliver
    end
  end

  def start_tonight
    AdventJob.schedule Time.now.utc.end_of_day
  end
end