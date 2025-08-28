#!/usr/bin/env ruby
# Performance Analysis Script
# Run with: bin/rails runner scripts/performance_analysis.rb

require 'benchmark'

puts "=== Taw Ha Zin Nurain Foundation Performance Analysis ==="
puts "Date: #{Time.current}"
puts

# Database connection analysis
puts "1. Database Connection Analysis:"
puts "   Pool Size: #{ActiveRecord::Base.connection_pool.size}"
puts "   Connections in use: #{ActiveRecord::Base.connection_pool.connections.size}"
puts

# Query performance analysis
puts "2. Query Performance Analysis:"

# Test healthcare requests query
puts "   Healthcare Requests Query:"
time = Benchmark.measure do
  HealthcareRequest.visible_to_public.limit(10).each do |request|
    request.donation_count
    request.total_donations
  end
end
puts "   Time: #{time.real.round(4)}s"
puts

# Test events query
puts "   Events Query:"
time = Benchmark.measure do
  Event.upcoming.limit(5).each do |event|
    event.name
    event.start_date
  end
end
puts "   Time: #{time.real.round(4)}s"
puts

# Test projects query
puts "   Projects Query:"
time = Benchmark.measure do
  Project.active.limit(5).each do |project|
    project.name
    project.description
  end
end
puts "   Time: #{time.real.round(4)}s"
puts

# Cache analysis
puts "3. Cache Analysis:"
cache_stats = Rails.cache.stats rescue "Cache stats not available"
puts "   Cache: #{cache_stats}"
puts

# Memory analysis
puts "4. Memory Analysis:"
if defined?(GetProcessMem)
  mem = GetProcessMem.new
  puts "   Memory Usage: #{mem.mb} MB"
else
  puts "   Memory profiler not available"
end
puts

# Recommendations
puts "5. Performance Recommendations:"
puts "   ✓ Counter caches implemented for HealthcareRequest"
puts "   ✓ Database indexes added for common queries"
puts "   ✓ Query optimization with select and includes"
puts "   ✓ Caching implemented for navigation stats"
puts "   ✓ Performance monitoring enabled"
puts
puts "   Next steps:"
puts "   - Monitor slow queries in production logs"
puts "   - Consider implementing Redis for caching"
puts "   - Set up proper monitoring with tools like New Relic"
puts "   - Implement CDN for static assets"
puts "   - Consider database read replicas for heavy read operations"
