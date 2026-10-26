module SearchSelectInput
  class SuggestionsComponent < ViewComponent::Base
    include Turbo::FramesHelper

    delegate :records, :selected_ids, :param_scope, to: :state

    def initialize(state:, value_method:, text_method:)
      super()
      @state = state
      @value_method = value_method
      @text_method = text_method
    end

    private

    attr_reader :state

    def frame_id = SearchSelect.frame_id_for(model_class, param_scope)

    def model_class
      return @model_class if instance_variable_defined?(:@model_class)

      @model_class = if records.respond_to?(:model)
                       records.model
                     elsif records.respond_to?(:klass)
                       records.klass
                     end
    end

    def value_for(record) = record.public_send(@value_method).to_s
    def text_for(record) = record.public_send(@text_method).to_s
    def selected?(record) = selected_ids.include?(value_for(record))
  end
end
