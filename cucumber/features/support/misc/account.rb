# Current account data
module Account
  class << self
    attr_accessor :type
    attr_accessor :name
    attr_accessor :email
    attr_accessor :level
    attr_accessor :account_status
    attr_accessor :active_friends_number
  end
end
