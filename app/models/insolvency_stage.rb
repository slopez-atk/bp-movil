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

class InsolvencyStage < ApplicationRecord
  has_many :insolvency_activities

  def self.collection
    InsolvencyStage.select("id, name").map {|x| [x.id, x.name] }
  end

  def get_activities
    self.insolvency_activities.select("id, name").map {|x| [x.id, x.name] }
  end
end
