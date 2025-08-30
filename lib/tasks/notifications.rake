namespace :notifications do
  desc "Backfill a welcome notification for all users"
  task backfill_welcome: :environment do
    User.find_each do |user|
      Notification.create!(recipient: user, title: 'Welcome', body: 'Welcome to Taw Ha Zin Foundation')
    end
    puts "Backfilled welcome notifications for #{User.count} users"
  end
end
