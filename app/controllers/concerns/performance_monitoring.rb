module PerformanceMonitoring
  extend ActiveSupport::Concern

  included do
    around_action :monitor_performance
  end

  private

  def monitor_performance
    start_time = Time.current
    yield
  ensure
    duration = Time.current - start_time
    Rails.logger.info "#{controller_name}##{action_name} took #{duration.round(3)}s"

    # Log slow requests (>500ms)
    if duration > 0.5
      Rails.logger.warn "SLOW REQUEST: #{controller_name}##{action_name} took #{duration.round(3)}s"
    end
  end
end
