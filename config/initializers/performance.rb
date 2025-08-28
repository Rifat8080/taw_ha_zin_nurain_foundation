# Performance monitoring and optimization settings
require "rack-mini-profiler" if Rails.env.development?

# Enable memory profiling in development
if Rails.env.development?
  require "memory_profiler"
  require "flamegraph"
end

# Configure Redis for caching (if available)
if ENV["REDIS_URL"].present?
  Rails.application.config.cache_store = :redis_cache_store, {
    url: ENV["REDIS_URL"],
    pool_size: ENV.fetch("RAILS_MAX_THREADS", 5).to_i,
    pool_timeout: 5
  }
end

# Performance monitoring
Rails.application.config.middleware.use Rack::MiniProfiler if Rails.env.development?

# Enable query logging tags for better debugging
Rails.application.config.active_record.query_log_tags_enabled = true
Rails.application.config.active_record.query_log_tags = [
  :application,
  :controller,
  :action,
  :job
]

# Optimize Active Record
Rails.application.config.active_record.verbose_query_logs = false
Rails.application.config.active_record.async_query_executor = :global_thread_pool

# Enable compression
Rails.application.config.middleware.use Rack::Deflater

# Optimize asset serving
Rails.application.config.public_file_server.headers = {
  "Cache-Control" => "public, max-age=31536000, immutable"
}
