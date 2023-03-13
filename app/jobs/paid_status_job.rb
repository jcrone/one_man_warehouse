class PaidStatusJob < ApplicationJob
  queue_as :default

  def perform(hour)
    @hour = Hour.find(hour)
    @hour.paid!
  end
end
