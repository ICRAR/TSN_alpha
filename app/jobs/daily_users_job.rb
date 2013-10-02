class DailyUsersJob
  def self.perform
    Benchmark.measure do
      csv = CSV.generate({}) do |csv|
        csv << ["id"]
        User.where{(last_sign_in_at > 1.day.ago) | (current_sign_in_at > 1.day.ago)}.includes(:profile).each do |u|
          if u.profile.nil?
            puts u.to_yaml
          else
            csv << [u.profile.id]
          end
        end
      end
      file = Rails.root.join('tmp', 'sign_in_today.csv')
      File.open(file, "w") { |file| file.write csv }
    end
  end
  def run_tonight
    time = Time.at(Time.now.end_of_day - 8.hours)
    DailyUsersJob.delay(:run_at => time).perform
  end
end