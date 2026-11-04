# Demo accounts for local development. The password is not for a public server.
demo_password = "password"

User.find_or_create_by!(email_address: "admin@example.com") do |user|
  user.password = demo_password
  user.password_confirmation = demo_password
  user.role = :admin
end

citizen_user = User.find_or_create_by!(email_address: "citizen@example.com") do |user|
  user.password = demo_password
  user.password_confirmation = demo_password
  user.role = :citizen
end

citizen = citizen_user.citizen || citizen_user.create_citizen!(
  name: "Demo Citizen",
  email: citizen_user.email_address
)

health = Service.find_or_create_by!(name: "Health Card Renewal") do |service|
  service.description = "Renew your provincial health card"
end

Service.find_or_create_by!(name: "Driver's Licence") do |service|
  service.description = "Renew your driver's licence"
end

Consent.find_or_create_by!(citizen: citizen, service: health)
