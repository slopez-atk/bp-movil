# == Schema Information
#
# Table name: permission_histories
#
#  id                :integer          not null, primary key
#  worker_id         :integer
#  descripcion       :string
#  fecha_permiso     :string
#  fecha_eliminacion :string
#  horas             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class PermissionHistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
