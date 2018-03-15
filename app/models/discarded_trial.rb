# == Schema Information
#
# Table name: discarded_trials
#
#  id         :integer          not null, primary key
#  juicio_id  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DiscardedTrial < ApplicationRecord
end
