# == Schema Information
#
# Table name: worker_planifications
#
#  id              :integer          not null, primary key
#  worker_id       :integer
#  start_date      :date
#  end_date        :date
#  horas_estimadas :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class WorkerPlanificationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
