class ModalComponent < ViewComponent::Base
  def initialize(title:)
    super()
    @title = title
  end

  private

  attr_reader :title
end
