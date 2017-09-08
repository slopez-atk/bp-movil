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

require 'test_helper'

class GoodActivityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
