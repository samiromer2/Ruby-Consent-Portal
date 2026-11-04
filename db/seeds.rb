# Demo admin so the service catalog can be managed locally.
# Password is for development only.
User.find_or_create_by!(email_address: "admin@example.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
  user.role = :admin
end
