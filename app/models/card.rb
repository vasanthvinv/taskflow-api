class Card < ApplicationRecord
  belongs_to :list
  belongs_to :user, optional: true

  validates :title, presence: true
  default_scope { order(:position) }

  LABELS = %w[bug feature urgent low-priority review].freeze
end
