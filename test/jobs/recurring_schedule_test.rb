require "test_helper"

class RecurringScheduleTest < ActiveSupport::TestCase
  test "stale consents expire every night in development and production" do
    schedule = YAML.safe_load_file(Rails.root.join("config/recurring.yml"), aliases: true)

    %w[development production].each do |env|
      task = schedule.fetch(env).fetch("expire_stale_consents")
      assert_equal "ExpireStaleConsentsJob", task.fetch("class")
      assert_equal "at 3am every day", task.fetch("schedule")
    end
  end
end
