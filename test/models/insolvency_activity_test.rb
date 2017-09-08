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

require 'test_helper'

class InsolvencyActivityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
