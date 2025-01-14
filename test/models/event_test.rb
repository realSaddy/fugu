# == Schema Information
#
# Table name: events
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  properties :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  api_key_id :bigint           not null
#
# Indexes
#
#  index_events_on_api_key_id  (api_key_id)
#
# Foreign Keys
#
#  fk_rails_...  (api_key_id => api_keys.id)
#
require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "has a valid factory" do
    assert build(:event)
  end

  context "validations" do
    subject { build(:event) }

    should validate_presence_of(:name)

    should belong_to(:api_key)

    should_not allow_value("Non JSON String").for(:properties)
    should_not allow_value("{invalid_json: \"12\"}").for(:properties)

    should_not allow_value("a-", "a$", "a_").for(:name)

    should validate_length_of(:name).is_at_most(25)
    should validate_exclusion_of(:name)
      .in_array(%w[all])
      .with_message("'all' is a reversed event name by Fugu and can't be used")
      should validate_exclusion_of(:name)
      .in_array(%w[All])
      .with_message("'All' is a reversed event name by Fugu and can't be used")
  end
end
