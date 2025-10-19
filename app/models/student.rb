class Student < ApplicationRecord
  belongs_to :user
  belongs_to :school
  belongs_to :grade
  has_many :attendances, dependent: :destroy

  alias_attribute :name, :student_name
end
