class DailyUsersRacJob
  def self.perform
    Benchmark.measure do
      csv = CSV.generate({}) do |csv|
        csv << ["id", "rac"]
        GeneralStatsItem.where{recent_avg_credit > 10}.each do |g|
          csv << [g.profile_id,g.recent_avg_credit]
        end
      end
      file = Rails.root.join('tmp', 'rac_today.csv')
      File.open(file, "w") { |file| file.write csv }
    end
  end
  def run_tonight
    time = Time.at(Time.now.end_of_day)
    DailyUsersRacJob.delay(:run_at => time).perform
  end
end