# == Schema Information
#
# Table name: history_credits
#
#  id           :integer          not null, primary key
#  credit_id    :string
#  socio_id     :string
#  cedula       :string
#  agencia      :string
#  abogado      :string
#  asesor       :string
#  estado       :string
#  semaforo     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  mes          :string
#  tipo_credito :string
#  user_id      :integer
#

require 'test_helper'

class HistoryCreditTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
