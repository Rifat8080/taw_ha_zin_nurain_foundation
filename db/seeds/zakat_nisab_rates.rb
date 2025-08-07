# Create sample Nisab rates for current and previous years
current_year = Date.current.year

# Current year rates (approximate 2025 rates)
NisabRate.find_or_create_by(year: current_year) do |rate|
  rate.gold_price_per_gram = 75.50  # Approximate gold price per gram in USD
  rate.silver_price_per_gram = 0.95 # Approximate silver price per gram in USD
end

# Previous year for comparison
NisabRate.find_or_create_by(year: current_year - 1) do |rate|
  rate.gold_price_per_gram = 73.20
  rate.silver_price_per_gram = 0.88
end

puts "Created Nisab rates for #{current_year} and #{current_year - 1}"
puts "Gold Nisab (85g): $#{NisabRate.find_by(year: current_year).nisab_gold}"
puts "Silver Nisab (595g): $#{NisabRate.find_by(year: current_year).nisab_silver}"
puts "Minimum Nisab Threshold: $#{NisabRate.find_by(year: current_year).min_nisab}"
