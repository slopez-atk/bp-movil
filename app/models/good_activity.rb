# == Schema Information
#
# Table name: good_activities
#
#  id            :integer          not null, primary key
#  name          :string
#  good_stage_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class GoodActivity < ApplicationRecord
  belongs_to :good_stage
end
