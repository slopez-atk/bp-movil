# == Schema Information
#
# Table name: without_good_activities
#
#  id                   :integer          not null, primary key
#  name                 :string
#  withoutgood_stage_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class WithoutGoodActivity < ApplicationRecord
  belongs_to :withoutgood_stage
end
