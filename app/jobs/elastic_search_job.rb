class ElasticSearchJob
  include Delayed::ScheduledJob
  run_every 5.minutes

  def perform
    begin
      Profile.search("test",1,10)
    rescue Errno::ECONNREFUSED
      call = "sudo service elasticsearch restart "
      AdminMailer.debug("Elastic Search has been restarted", "ES Restart").deliver
      system "/bin/bash -l -c '" + call + "'"
    end
  end
end