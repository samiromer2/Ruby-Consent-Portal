json.extract! consent, :id, :citizen_id, :service_id, :granted_at, :revoked_at, :created_at, :updated_at
json.url consent_url(consent, format: :json)
