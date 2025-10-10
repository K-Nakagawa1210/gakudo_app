class Student < ApplicationRecord
  belongs_to :school
  belongs_to :grade
  has_many :attendances, dependent: :destroy
end
