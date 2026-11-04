require "test_helper"

class ConsentEventTest < ActiveSupport::TestCase
  test "a granted or revoked event needs a user" do
    event = ConsentEvent.new(consent: consents(:one), action: :granted)

    assert_not event.valid?
    assert event.errors[:user].any?
  end

  test "an expired event can belong to the system" do
    event = ConsentEvent.new(consent: consents(:old), action: :expired)

    assert event.valid?
    assert_equal "System", event.actor_name
  end

  test "a saved event cannot be edited or deleted" do
    event = consents(:one).consent_events.create!(action: :granted, user: users(:one))

    assert_raises(ActiveRecord::ReadOnlyRecord) { event.update!(action: :revoked) }
    assert_raises(ActiveRecord::ReadOnlyRecord) { event.destroy! }
    assert_equal 1, consents(:one).consent_events.count
  end
end
