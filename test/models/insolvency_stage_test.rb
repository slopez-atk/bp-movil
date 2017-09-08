# == Schema Information
#
# Table name: insolvency_stages
#
#  id         :integer          not null, primary key
#  name       :string
#  months     :integer
#  days       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class InsolvencyStageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
