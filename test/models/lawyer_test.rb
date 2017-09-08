# == Schema Information
#
# Table name: lawyers
#
#  id         :integer          not null, primary key
#  name       :string
#  lastname   :string
#  phone      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class LawyerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
