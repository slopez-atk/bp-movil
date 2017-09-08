# == Schema Information
#
# Table name: withoutgood_stages
#
#  id         :integer          not null, primary key
#  name       :string
#  months     :integer
#  days       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WithoutgoodStage < ApplicationRecord
  has_many :without_good_activities

  def self.collection
    WithoutgoodStage.select("id, name").map {|x| [x.id, x.name] }
  end

  def get_activities
    self.without_good_activities.select("id, name").map {|x| [x.id, x.name] }
  end
end
