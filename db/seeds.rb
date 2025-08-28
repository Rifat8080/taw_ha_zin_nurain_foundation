# --- Extra Demo Seeds: 13 Projects, 13 HealthcareRequests, 13 Events ---
if Project.count < 13
  (Project.count...13).each do |i|
    Project.create!(
      name: "Demo Project #{i+1}",
      description: "Description for Demo Project #{i+1} - supporting the Ummah.",
      is_active: true
    )
  end
  puts "Seeded demo projects: #{Project.count} total."
end

if HealthcareRequest.count < 13
  demo_user = User.first
  (HealthcareRequest.count...13).each do |i|
    HealthcareRequest.create!(
      patient_name: "Demo Patient #{i+1}",
      reason: "Medical need for Demo Patient #{i+1}.",
      status: "approved",
      approved: true,
      user: demo_user
    )
  end
  puts "Seeded demo healthcare requests: #{HealthcareRequest.count} total."
end

if Event.count < 13
  (Event.count...13).each do |i|
    Event.create!(
      name: "Demo Event #{i+1}",
      start_date: Date.today + i.days,
      end_date: Date.today + i.days,
      start_time: Time.now.change(hour: 10, min: 0),
      end_time: Time.now.change(hour: 14, min: 0),
      total_seats: 100 + i,
      venue: "Venue #{i+1}, City Center",
      guest_list: "Guest Speaker #{i+1}",
      guest_description: "Join us for Demo Event #{i+1} to support our cause.",
      ticket_price: 100 + i * 10,
      ticket_category: "general"
    )
  end
  puts "Seeded demo events: #{Event.count} total."
end
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Load Zakat Nisab rates
load Rails.root.join('db', 'seeds', 'zakat_nisab_rates.rb')

# Create sample users if they don't exist
if User.count == 0
  admin_user = User.create!(
    first_name: "John",
    last_name: "Admin",
    email: "admin@example.com",
    phone_number: 1234567800,
    password: "password123",
    password_confirmation: "password123",
    role: "admin",
    address: "123 Admin Street, City, State"
  )

  regular_user = User.create!(
    first_name: "Jane",
    last_name: "Doe",
    email: "jane@example.com",
    phone_number: 1234567801,
    password: "password123",
    password_confirmation: "password123",
    role: "member",
    address: "456 User Avenue, City, State"
  )

  volunteer_user = User.create!(
    first_name: "Bob",
    last_name: "Volunteer",
    email: "bob@example.com",
    phone_number: 1234567802,
    password: "password123",
    password_confirmation: "password123",
    role: "volunteer",
    address: "789 Volunteer Lane, City, State"
  )

  puts "Created #{User.count} users"
end

# Create sample events
if Event.count < 3
  # Upcoming event
  Event.create!(
    name: "Annual Charity Gala",
    start_date: Date.current + 30.days,
    end_date: Date.current + 30.days,
    start_time: Time.parse("18:00"),
    end_time: Time.parse("23:00"),
    total_seats: 200,
    venue: "Grand Ballroom, Luxury Hotel, Downtown",
    guest_list: "Special guest speaker: Dr. Sarah Johnson, renowned philanthropist\nPerformance by the City Orchestra\nAward ceremony for outstanding volunteers",
    guest_description: "Join us for an elegant evening of giving back to the community. This annual gala brings together supporters, volunteers, and beneficiaries to celebrate our achievements and raise funds for future projects. Enjoy a three-course dinner, live entertainment, and inspiring stories from those we've helped.",
    ticket_price: 150,
    ticket_category: "premium"
  )

  # Upcoming event 2
  Event.create!(
    name: "Community Workshop: Digital Literacy",
    start_date: Date.current + 60.days,
    end_date: Date.current + 62.days,
    start_time: Time.parse("09:00"),
    end_time: Time.parse("17:00"),
    total_seats: 50,
    venue: "Community Center, Room A & B",
    guest_list: "Workshop facilitators:\n- Tech expert Alex Chen\n- Senior trainer Maria Rodriguez\n- Digital inclusion specialist David Kim",
    guest_description: "A comprehensive 3-day workshop designed to help community members develop essential digital skills. Topics include basic computer operations, internet safety, online banking, social media basics, and accessing government services online. All skill levels welcome!",
    ticket_price: 25,
    ticket_category: "general"
  )

  # Upcoming event 3
  Event.create!(
    name: "Live Concert: Local Artists Showcase",
    start_date: Date.current + 45.days,
    end_date: Date.current + 45.days,
    start_time: Time.parse("19:30"),
    end_time: Time.parse("22:30"),
    total_seats: 100,
    venue: "Riverside Amphitheater",
    guest_list: "Featured Artists:\n- Indie rock band 'Midnight Echo'\n- Folk singer-songwriter Lisa Thompson\n- Jazz trio 'Blue Note Collective'\n- Hip-hop artist MC Flow",
    guest_description: "An evening celebrating local musical talent with performances across multiple genres. Support emerging artists while enjoying an intimate concert experience under the stars. Proceeds benefit our youth music education programs.",
    ticket_price: 75,
    ticket_category: "vip"
  )

  puts "Created #{Event.count} sample events"
end

puts "\nSeed data creation completed!"
puts "Events: #{Event.count}"
puts "Tickets: #{Ticket.count}"
puts "Event Registrations: #{EventUser.count}"
puts "Users: #{User.count}"

# Create sample users for testing
puts "Creating sample users..."

admin_user = User.find_or_create_by!(email: "admin@tawhazin.org") do |user|
  user.first_name = "Admin"
  user.last_name = "User"
  user.phone_number = 1234567810
  user.role = "admin"
  user.address = "123 Foundation St, Dhaka"
  user.password = "password123"
  user.password_confirmation = "password123"
end

member_users = []
5.times do |i|
  member_user = User.find_or_create_by!(email: "member#{i+1}@tawhazin.org") do |user|
    user.first_name = "Member"
    user.last_name = "#{i+1}"
    user.phone_number = 1234567811 + i  # Unique phone numbers for each member
    user.role = "member"
    user.address = "#{i+1}23 Member St, Dhaka"
    user.password = "password123"
    user.password_confirmation = "password123"
  end
  member_users << member_user
end

puts "Created #{User.count} users"

# Create volunteer teams
puts "Creating volunteer teams..."

teams = [
  { name: "Education Support Team", district: "Dhaka" },
  { name: "Healthcare Outreach Team", district: "Chittagong" },
  { name: "Food Distribution Team", district: "Sylhet" },
  { name: "Emergency Response Team", district: "Rajshahi" }
]

created_teams = []
teams.each do |team_data|
  team = VolunteersTeam.find_or_create_by!(name: team_data[:name]) do |team|
    team.district = team_data[:district]
  end
  created_teams << team
end

puts "Created #{VolunteersTeam.count} teams"

# Create volunteers
puts "Creating volunteers..."

volunteer_roles = %w[coordinator member leader supervisor]

member_users.each_with_index do |user, index|
  volunteer = Volunteer.find_or_create_by!(user: user) do |vol|
    vol.joining_date = Date.current - rand(365).days
    vol.role = volunteer_roles.sample
  end

  # Assign volunteers to teams
  if created_teams.any?
    team = created_teams.sample
    TeamAssignment.find_or_create_by!(volunteer: volunteer, team_id: team.id)
  end
end

puts "Created #{Volunteer.count} volunteers"
puts "Created #{TeamAssignment.count} team assignments"

# Create sample projects
puts "Creating sample projects..."

projects = [
  {
    name: "School Building Project",
    categories: "Education, Infrastructure",
    description: "Building new classrooms for underprivileged children",
    is_active: true
  },
  {
    name: "Medical Camp Initiative",
    categories: "Healthcare, Community Service",
    description: "Free medical checkups in rural areas",
    is_active: true
  }
]

created_projects = []
projects.each do |project_data|
  project = Project.find_or_create_by!(name: project_data[:name]) do |proj|
    proj.categories = project_data[:categories]
    proj.description = project_data[:description]
    proj.is_active = project_data[:is_active]
  end
  created_projects << project
end

puts "Created #{Project.count} projects"

# Create work orders
puts "Creating work orders..."

work_orders = [
  {
    title: "Conduct Community Survey",
    description: "Survey the local community to understand their educational needs and identify potential beneficiaries for our school building project.",
    checklist: "1. Prepare survey questionnaires\n2. Visit 50 households\n3. Interview community leaders\n4. Compile survey results\n5. Submit final report",
    assigned_date: Date.current + 7.days
  },
  {
    title: "Organize Medical Equipment Collection",
    description: "Collect and organize medical equipment donations for the upcoming medical camp.",
    checklist: "1. Contact medical suppliers\n2. Arrange pickup of donations\n3. Check equipment condition\n4. Organize equipment by category\n5. Create inventory list",
    assigned_date: Date.current + 14.days
  },
  {
    title: "Food Package Distribution",
    description: "Distribute food packages to 100 families in need during the month of Ramadan.",
    checklist: "1. Prepare food packages\n2. Create beneficiary list\n3. Arrange distribution point\n4. Coordinate volunteers\n5. Document distribution",
    assigned_date: Date.current - 5.days
  }
]

work_orders.each_with_index do |wo_data, index|
  if created_teams.any?
    WorkOrder.find_or_create_by!(title: wo_data[:title]) do |wo|
      wo.description = wo_data[:description]
      wo.checklist = wo_data[:checklist]
      wo.assigned_date = wo_data[:assigned_date]
      wo.team_id = created_teams[index % created_teams.length].id
      wo.assigned_by = admin_user.id
    end
  end
end

puts "Created #{WorkOrder.count} work orders"

# Create sample healthcare requests
healthcare_requests_data = [
  {
    patient_name: "Ahmed Rahman",
    reason: "Urgent heart surgery required. Patient has been diagnosed with severe coronary artery disease and needs immediate bypass surgery. The estimated cost is 500,000 BDT including surgery, hospital stay, and medications. The family cannot afford this treatment without community support.",
    prescription_url: "https://example.com/prescription1.pdf",
    status: "approved",
    approved: true
  },
  {
    patient_name: "Fatima Begum",
    reason: "Cancer treatment and chemotherapy. Patient diagnosed with breast cancer and requires immediate chemotherapy sessions. Total treatment cost estimated at 300,000 BDT. Single mother with no steady income source.",
    prescription_url: "https://example.com/prescription2.pdf",
    status: "pending",
    approved: false
  },
  {
    patient_name: "Mohammad Ali",
    reason: "Kidney transplant surgery needed. Patient has been on dialysis for 2 years and requires urgent kidney transplant. Surgery and post-operative care will cost approximately 800,000 BDT.",
    prescription_url: nil,
    status: "approved",
    approved: true
  },
  {
    patient_name: "Rashida Khatun",
    reason: "Emergency eye surgery to prevent blindness. Patient has severe glaucoma and needs immediate surgery to save vision. Family struggling financially due to COVID-19 impact.",
    prescription_url: "https://example.com/prescription4.pdf",
    status: "completed",
    approved: true
  }
]

healthcare_requests_data.each_with_index do |req_data, index|
  user = member_users[index % member_users.length]
  request = HealthcareRequest.find_or_create_by!(patient_name: req_data[:patient_name]) do |hr|
    hr.user = user
    hr.reason = req_data[:reason]
    hr.prescription_url = req_data[:prescription_url]
    hr.status = req_data[:status]
    hr.approved = req_data[:approved]
    hr.created_at = (index + 1).days.ago
  end

  # Add some donations to approved requests
  if request.approved? && request.status == 'approved'
    donation_amounts = [ 1000, 2500, 5000, 1500, 3000, 500, 10000 ]
    rand(3..6).times do |i|
      donor = member_users[(index + i + 1) % member_users.length]
      unless donor == request.user
        HealthcareDonation.find_or_create_by!(
          user: donor,
          healthcare_request: request,
          amount: donation_amounts[i % donation_amounts.length]
        ) do |donation|
          donation.created_at = rand(0..2).days.ago
        end
      end
    end
  end
end

puts "Created #{HealthcareRequest.count} healthcare requests"
puts "Created #{HealthcareDonation.count} healthcare donations"

puts "Sample data creation completed!"
puts "You can now test the volunteer management system with:"
puts "- #{User.count} users (1 admin, #{member_users.count} members)"
puts "- #{VolunteersTeam.count} volunteer teams"
puts "- #{Volunteer.count} volunteers"
puts "- #{TeamAssignment.count} team assignments"
puts "- #{Project.count} projects"
puts "- #{WorkOrder.count} work orders"
puts "- #{HealthcareRequest.count} healthcare requests"
puts "- #{HealthcareDonation.count} healthcare donations"
