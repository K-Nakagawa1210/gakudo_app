class Grade < ApplicationRecord
  alias_attribute :grade_name, :name
  
  has_many :students

  validates :name, presence: true
  validates :level, presence: true
  validates :year, presence: true
end
