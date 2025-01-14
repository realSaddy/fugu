# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_projects_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Project < ApplicationRecord
  has_many :api_keys, dependent: :destroy
  belongs_to :user

  validates :name,
            presence: true,
            uniqueness: {
              scope: :user_id,
              message: "You already have a project with this name",
              case_insensitive: true
            },
            format:
              {
                with: /\A[a-zA-Z0-9-]*\z/,
                message: "can only contain numbers, letters and hypens allowed"
              },
            exclusion:
              {
                in: %w[project projects],
                message: "'%{value}' is a reversed event name by Fugu and can't be used"
              }
  validates :user, presence: true

  before_validation :downcase_name
  before_validation :strip_name

  PROJECT_PARAMS = %i[slug test event prop agg date].freeze

  def downcase_name
    self.name = name.downcase if name
  end

  def strip_name
    self.name = name.strip if name
  end

  def create_api_keys
    ApiKey.create(project: self, test: false)
    ApiKey.create(project: self, test: true)
  end

  def api_key_live
    api_keys.find_by(test: false)
  end

  def api_key_test
    api_keys.find_by(test: true)
  end
end
