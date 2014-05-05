class ElasticSearchJob < Delayed::BaseScheduledJob
  run_every 5.minutes

  def perform
    begin
      Profile.search("test",1,10)
    rescue => e
      call = "sudo service elasticsearch restart "
      msg =  "Elastic Search has been restarted\n\n"
      msg +=  e.to_s
      msg += "\n\n"
      msg += e.backtrace.join("\n")
      AdminMailer.debug(msg, "ES Restart").deliver
      system "/bin/bash -l -c '" + call + "'"
    end
  end
end