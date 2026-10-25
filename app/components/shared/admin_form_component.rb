module Shared
  class AdminFormComponent < ViewComponent::Base
    def initialize(admin:)
      super()
      @admin = admin
    end
  end
end
