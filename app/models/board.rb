class Board < ApplicationRecord
  belongs_to :user
  has_many :lists, dependent: :destroy

  validates :title, presence: true

  COLORS = %w[#ef4444 #f97316 #eab308 #22c55e #3b82f6 #8b5cf6 #ec4899].freeze
end
