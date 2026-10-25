module Admins
  class FormComponent < ViewComponent::Base
    def initialize(admin:)
      super()
      @admin = admin
    end

    private

    attr_reader :admin
  end
end
