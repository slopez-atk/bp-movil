# == Schema Information
#
# Table name: vacations
#
#  id                :integer          not null, primary key
#  worker_id         :integer
#  fecha_permiso     :date
#  descripcion       :string
#  horas             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  fecha_terminacion :date
#

class Vacation < ApplicationRecord
  belongs_to :worker
end
