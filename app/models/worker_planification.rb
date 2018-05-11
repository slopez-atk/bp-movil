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

class WorkerPlanification < ApplicationRecord
  belongs_to :worker
end
