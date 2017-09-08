# == Schema Information
#
# Table name: good_stages
#
#  id         :integer          not null, primary key
#  name       :string
#  months     :integer
#  days       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GoodStage < ApplicationRecord
  has_many :good_activities

  def self.collection
    GoodStage.select("id, name").map {|x| [x.id, x.name] }
  end

  def get_activities
    self.good_activities.select("id, name").map {|x| [x.id, x.name] }
  end
end
