# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Fictional sample records for local development and demos. These names, badges,
# incidents, cases, histories, and decisions do not describe real people or events.
seed_user = User.find_by(email: "sample-directory@codeblue7.local")
unless seed_user
	seed_user = User.create!(
		email: "sample-directory@codeblue7.local",
		password: SecureRandom.hex(32),
		display_name: "Sample Directory Data"
	)
end

sample_officials = [
	{ category: :police_officer, name: "Sample Police Officer 1", district: "Manhattan North", badge_number: "DEMO-1001", precinct: "20th Precinct", incident_names: "Fictional incident DEMO-NYC-001" },
	{ category: :police_officer, name: "Sample Police Officer 2", district: "Manhattan South", badge_number: "DEMO-1002", precinct: "13th Precinct", incident_names: "Fictional incident DEMO-NYC-002" },
	{ category: :police_officer, name: "Sample Police Officer 3", district: "Brooklyn North", badge_number: "DEMO-1003", precinct: "79th Precinct", incident_names: "Fictional incident DEMO-NYC-003" },
	{ category: :police_officer, name: "Sample Police Officer 4", district: "Queens South", badge_number: "DEMO-1004", precinct: "105th Precinct", incident_names: "Fictional incident DEMO-NYC-004" },
	{ category: :police_officer, name: "Sample Police Officer 5", district: "Bronx", badge_number: "DEMO-1005", precinct: "44th Precinct", incident_names: "Fictional incident DEMO-NYC-005" },
	{ category: :district_attorney, name: "Sample District Attorney 1", case_number: "DEMO-DA-2026-001", history: "Fictional sample case history.", decisions: "Demonstration only; no real decision." },
	{ category: :district_attorney, name: "Sample District Attorney 2", case_number: "DEMO-DA-2026-002", history: "Fictional sample case history.", decisions: "Demonstration only; no real decision." },
	{ category: :district_attorney, name: "Sample District Attorney 3", case_number: "DEMO-DA-2026-003", history: "Fictional sample case history.", decisions: "Demonstration only; no real decision." },
	{ category: :district_attorney, name: "Sample District Attorney 4", case_number: "DEMO-DA-2026-004", history: "Fictional sample case history.", decisions: "Demonstration only; no real decision." },
	{ category: :district_attorney, name: "Sample District Attorney 5", case_number: "DEMO-DA-2026-005", history: "Fictional sample case history.", decisions: "Demonstration only; no real decision." },
	{ category: :judge, name: "Sample Judge 1", case_number: "DEMO-J-2026-001", history: "Fictional sample case history.", decisions: "Demonstration only; no real decision." },
	{ category: :judge, name: "Sample Judge 2", case_number: "DEMO-J-2026-002", history: "Fictional sample case history.", decisions: "Demonstration only; no real decision." },
	{ category: :judge, name: "Sample Judge 3", case_number: "DEMO-J-2026-003", history: "Fictional sample case history.", decisions: "Demonstration only; no real decision." },
	{ category: :judge, name: "Sample Judge 4", case_number: "DEMO-J-2026-004", history: "Fictional sample case history.", decisions: "Demonstration only; no real decision." },
	{ category: :judge, name: "Sample Judge 5", case_number: "DEMO-J-2026-005", history: "Fictional sample case history.", decisions: "Demonstration only; no real decision." }
]

sample_officials.each do |attributes|
	category = attributes.fetch(:category)
	name = attributes.fetch(:name)
	official = OfficialRecord.find_or_initialize_by(category: category, name: name, city: "New York City", state: "New York")
	official.assign_attributes(attributes.except(:category, :name).merge(user: seed_user))
	official.save!
end

puts "Seeded #{OfficialRecord.where(user: seed_user).count} fictional sample officials in New York City."
