# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample users for testing
puts "Creating sample users..."

admin_user = User.find_or_create_by!(email: "admin@tawhazin.org") do |user|
  user.first_name = "Admin"
  user.last_name = "User"
  user.phone_number = 1234567890
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
    user.phone_number = 1234567891 + i  # Start from a different number to avoid conflicts
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
    project_status_active: true
  },
  {
    name: "Medical Camp Initiative",
    categories: "Healthcare, Community Service",
    description: "Free medical checkups in rural areas",
    project_status_active: true
  }
]

created_projects = []
projects.each do |project_data|
  project = Project.find_or_create_by!(name: project_data[:name]) do |proj|
    proj.categories = project_data[:categories]
    proj.description = project_data[:description]
    proj.project_status_active = project_data[:project_status_active]
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

puts "Sample data creation completed!"
puts "You can now test the volunteer management system with:"
puts "- #{User.count} users (1 admin, #{member_users.count} members)"
puts "- #{VolunteersTeam.count} volunteer teams"
puts "- #{Volunteer.count} volunteers"
puts "- #{TeamAssignment.count} team assignments"
puts "- #{Project.count} projects"
puts "- #{WorkOrder.count} work orders"
