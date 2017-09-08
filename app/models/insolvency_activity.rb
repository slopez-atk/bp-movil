# == Schema Information
#
# Table name: insolvency_activities
#
#  id                  :integer          not null, primary key
#  name                :string
#  insolvency_stage_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class InsolvencyActivity < ApplicationRecord
  belongs_to :insolvency_stage
end
