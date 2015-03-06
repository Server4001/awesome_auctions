# run: whenever to spit out cron
set :output, "#{path}/log/cron.log"

every 1.minute do
  runner "Auction.process_ended"
end
