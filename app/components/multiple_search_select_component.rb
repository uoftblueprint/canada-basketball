# A search box component used to select multiple records from a collection, backed by the server.
# When a query is typed into the search box, suggestions are streamed in using Turbo Frames.
# Each selected record appears as a removable badge below the input.
# Searching, selection, and badges are implemented using Turbo Frames and Stimulus so no full page reloads
# are triggered.
#
# This component is an interactive replacement for `collection_check_boxes`. It is useful when a collection
# has too many records for `collection_check_boxes` to be reasonable.
#
# Setting up this component takes three steps:
#   1. Model: declare the column you want to search on (the model must include Queryable).
#        class Player < ApplicationRecord
#          include Queryable
#          searchable_by :name
#        end
#
#   2. Controller: add a search action and route that renders the suggestions (the controller must
#      include SearchSelect). The param_scope here must match the one passed to the component.
#        include SearchSelect
#
#        def search
#          state = build_search_select_state(Player.all, param_scope: :players)
#          render SearchSelectInput::SuggestionsComponent.new(
#            state:,
#            value_method: :id,
#            text_method: :name
#          ), layout: false
#        end
#
#   3. View: render the component inside the form you want it to submit with.
#        <%= render MultipleSearchSelectComponent.new(
#              name: "#{f.object_name}[player_ids][]",
#              model: Player,
#              param_scope: :players,
#              selected: team.players,
#              label: "Players",
#              value_method: :id,
#              text_method: :name,
#              path_builder: ->(params) { search_players_path(params) }
#            ) %>
#
#      Or, inside a form using DefaultFormBuilder, use the following to infer most of the above
#
#        <%= f.multiple_search_select :player_ids, :id, :name %>
#
# `name:` is the form field name for each pick. Use the array form (ending in []) so several
# selections are submitted together.
#
# `model:` is the ActiveRecord class being searched.
#
# `path_builder:` is a lambda that takes a params hash and returns the search path.
#
# `selected:` is the records to show as already picked when the form first loads. Defaults to none.
#
# `param_scope:` namespaces the search params (q, selected) under a key and keeps the frame id
# unique. Pass unique scopes when a page has more than one search select components.
#
# `label:` and `placeholder:` are standard label and placeholders for form inputs.
#
# `value_method:` and `text_method:` determine, for each record, the value submitted and the label
# that is displayed. Both are required, the same way collection_check_boxes requires them.
class MultipleSearchSelectComponent < ViewComponent::Base
  def initialize(
    name:,
    model:,
    path_builder:,
    value_method:,
    text_method:,
    selected: [],
    param_scope: nil,
    label: nil,
    placeholder: "Search..."
  )
    super()
    @name = name
    @model = model
    @path_builder = path_builder
    @selected = selected
    @param_scope = param_scope
    @label = label
    @placeholder = placeholder
    @value_method = value_method
    @text_method = text_method
  end

  private

  attr_reader :name, :model, :selected, :param_scope, :label, :placeholder

  def url = @path_builder.call({})
  def value_for(record) = record.public_send(@value_method).to_s
  def text_for(record) = record.public_send(@text_method).to_s
end
