# == Schema Information
#
# Table name: workers
#
#  id              :integer          not null, primary key
#  fullname        :string
#  codigo          :string
#  agencia         :string
#  cargo           :string
#  fecha_ingreso   :date
#  fecha_calculo   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  dias_pendientes :float            default(0.0)
#

require 'test_helper'

class WorkerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
