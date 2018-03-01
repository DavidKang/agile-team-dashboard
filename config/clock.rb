require 'clockwork'

require './config/boot'
require './config/environment'
require 'English'

module Clockwork
  # Update Burndown Chart 5-20 minutes before the Standup and 30-45 after the Review
  every(15.minutes, "update burndown chart") do |job, local_time|
    Rails.logger.info "It is #{Time.zone.now.strftime('%F %T')}, running burndown chart update."
    times = { before_standup: 20.minutes, after_review: 30.minutes, interval: 15.minutes }

    ChartUpdater.update(Sprint.current, times)
  end
end
