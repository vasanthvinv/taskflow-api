class List < ApplicationRecord
  belongs_to :board
  has_many :cards, dependent: :destroy

  validates :title, presence: true
  default_scope { order(:position) }
end
