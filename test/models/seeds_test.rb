require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  test "demo seed can run twice" do
    2.times { Rails.application.load_seed }

    admin = User.find_by!(email_address: "admin@example.com")
    citizen_user = User.find_by!(email_address: "citizen@example.com")

    assert admin.admin?
    assert citizen_user.citizen?
    assert_equal "Demo Citizen", citizen_user.citizen.name
    assert citizen_user.citizen.consents.exists?(service: Service.find_by!(name: "Health Card Renewal"))
    assert_equal 1, User.where(email_address: "citizen@example.com").count
  end

  test "production databases have schema files" do
    raw = ERB.new(Rails.root.join("config/database.yml").read).result
    config = YAML.safe_load(raw, aliases: true).fetch("production")

    config.each_value do |settings|
      next unless settings.is_a?(Hash) && settings["migrations_paths"]

      schema = settings["migrations_paths"].sub(/_migrate\z/, "_schema.rb")
      assert Rails.root.join(schema).file?, "#{schema} is missing"
    end
  end
end
