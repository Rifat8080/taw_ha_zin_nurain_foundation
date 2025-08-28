class UpdateCounterCachesJob < ApplicationJob
  queue_as :maintenance

  def perform
    Rails.logger.info "Starting counter cache update job"

    # Update healthcare request counter caches
    HealthcareRequest.find_each do |request|
      request.update_counters
    end

    # Clear navigation stats cache to refresh with new data
    Rails.cache.delete("navigation_stats")

    Rails.logger.info "Counter cache update job completed"
  end
end
