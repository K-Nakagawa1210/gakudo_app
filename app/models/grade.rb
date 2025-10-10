class Grade < ApplicationRecord
  has_many :students

  validates :year, presence: true
  validates :level, presence: true, uniqueness: true
end
