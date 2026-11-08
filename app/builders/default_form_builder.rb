class DefaultFormBuilder < ActionView::Helpers::FormBuilder
  MERGER = TailwindMerge::Merger.new

  INPUT_CLASSES = "input h-12 w-full border-base-300 bg-base-200".freeze
  SELECT_CLASSES = "select h-12 w-full border-base-300 bg-base-200".freeze
  CHECKBOX_CLASSES = "checkbox border-base-300 not-checked:bg-base-200".freeze
  LABEL_CLASSES = "label text-lg font-medium whitespace-normal text-base-content".freeze

  FIELD_CLASSES = {
    email_field: INPUT_CLASSES,
    number_field: INPUT_CLASSES,
    password_field: INPUT_CLASSES,
    text_field: INPUT_CLASSES,
    textarea: "textarea w-full border-base-300 bg-base-200"
  }.freeze

  FIELD_CLASSES.each do |method_name, default_class|
    define_method(method_name) do |method, options = {}|
      add_class_to_options(options, default_class)
      super(method, options)
    end
  end

  def checkbox(method, options = {}, checked_value = "1", unchecked_value = "0")
    add_class_to_options(options, CHECKBOX_CLASSES)
    super
  end

  def collection_checkboxes(method, collection, value_method, text_method, options = {}, html_options = {}, &)
    add_class_to_options(html_options, CHECKBOX_CLASSES)
    super
  end

  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    add_class_to_options(html_options, SELECT_CLASSES)
    super
  end

  def label(method, text = nil, options = {}, &)
    if text.is_a?(Hash)
      options = text
      text = nil
    end
    add_class_to_options(options, LABEL_CLASSES)
    super
  end

  def select(method, choices = nil, options = {}, html_options = {}, &)
    add_class_to_options(html_options, SELECT_CLASSES)
    super
  end

  def submit(value = nil, options = {})
    if value.is_a?(Hash)
      options = value
      value = nil
    end
    add_class_to_options(options, "btn btn-primary h-12 w-full text-lg font-normal")
    super
  end

  # Rails aliases these to the original methods, so they would skip the styles above.
  alias text_area textarea
  alias check_box checkbox
  alias collection_check_boxes collection_checkboxes

  # Renders a MultipleSearchSelectComponent, inferring the field name, model,
  # label, and preselected records from the form object.
  # Pass a plural *_ids attribute, value_method, and text_method just like collection_check_boxes.
  #
  #   f.multiple_search_select :player_ids, :id, :name
  #   f.multiple_search_select :player_ids, :id, :name, label: "Roster"
  #
  # Other component parameters (placeholder:, param_scope:, etc.)
  # can be passed as arguments, which will override the inferred values
  def multiple_search_select(method, value_method, text_method, model: nil, path_builder: nil, label: nil,
                             **opts)
    association = method.to_s.delete_suffix("_ids").pluralize
    model ||= reflected_model(association)

    @template.render(
      MultipleSearchSelectComponent.new(
        name: "#{object_name}[#{method}][]",
        model: model,
        selected: object.public_send(association),
        label: label || object.class.human_attribute_name(association),
        path_builder: path_builder || default_path_builder(model),
        value_method: value_method,
        text_method: text_method,
        **opts
      )
    )
  end

  # Renders a SingleSearchSelectComponent, inferring the field name, model, label,
  # and preselected record from the form object.
  # Pass a *_id attribute, value_method, and text_method just like collection_select.
  #
  #   f.single_search_select :team_id, :id, :name
  #
  # Other component parameters (placeholder:, param_scope:, etc.)
  # can be passed as arguments, which will override the inferred values.
  def single_search_select(method, value_method, text_method, model: nil, path_builder: nil, label: nil, **opts)
    association = method.to_s.delete_suffix("_id")
    model ||= reflected_model(association)

    @template.render(
      SingleSearchSelectComponent.new(
        name: "#{object_name}[#{method}]",
        model: model,
        selected: object.public_send(association),
        label: label || object.class.human_attribute_name(association),
        path_builder: path_builder || default_path_builder(model),
        value_method: value_method,
        text_method: text_method,
        **opts
      )
    )
  end

  private

  # the caller's classes go last so they win over the defaults, e.g. class: "w-1/2" replaces w-full.
  def add_class_to_options(options, default_class)
    options[:class] = MERGER.merge(@template.class_names(default_class, options[:class]))
  end

  # finds the associated model class for an association name, e.g. "players" -> Player.
  def reflected_model(assoc)
    object.class.reflect_on_association(assoc.to_sym)&.klass ||
      raise(ArgumentError, "Could not infer a model for #{assoc.inspect}; pass model: explicitly")
  end

  # builds the search path by convention, e.g. Player -> search_players_path.
  def default_path_builder(model)
    route_helper = "search_#{model.model_name.route_key}_path"
    ->(params) { @template.public_send(route_helper, params) }
  end
end
