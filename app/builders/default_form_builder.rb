class DefaultFormBuilder < ActionView::Helpers::FormBuilder
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
