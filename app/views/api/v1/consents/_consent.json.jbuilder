json.id consent.id
json.status(consent.active? ? "active" : "revoked")
json.granted_at consent.granted_at
json.revoked_at consent.revoked_at
json.citizen do
  json.id consent.citizen.id
  json.name consent.citizen.name
  json.email consent.citizen.email
end
json.service do
  json.id consent.service.id
  json.name consent.service.name
end
