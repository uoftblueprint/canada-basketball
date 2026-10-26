module SearchSelectInput
  class FieldComponent < ViewComponent::Base
    include Turbo::FramesHelper

    def initialize(
      url:,
      model:,
      multiple:,
      param_scope: nil,
      label: nil,
      placeholder: "Search...",
      min_chars: 0,
      initial_query: nil
    )
      super()
      @url = url
      @model = model
      @multiple = multiple
      @param_scope = param_scope
      @label = label
      @placeholder = placeholder
      @min_chars = min_chars
      @initial_query = initial_query
    end

    private

    attr_reader :url, :label, :placeholder, :min_chars, :initial_query

    def multiple? = @multiple
    def frame_id = SearchSelect.frame_id_for(@model, @param_scope)
    def param_scope_value = @param_scope.to_s
  end
end
