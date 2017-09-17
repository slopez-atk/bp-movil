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

class Lawyer < ApplicationRecord
  has_many :goods
  has_many :without_goods
  has_many :insolvencies

  def full_name
    self.name + " " + self.lastname
  end
end
