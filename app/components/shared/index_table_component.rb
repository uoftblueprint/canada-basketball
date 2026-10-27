module Shared
  # Renders a searchable, sortable, and paginated table, backed by a database model.
  # Columns in the table ("table columns") corresponding to a column in the model ("model columns")
  # will have their values automatically rendered; a custom renderer can be added on top.
  #
  # If a model column is declared as 'searchable', records are filtered on the model column's values.
  # If a model column is declared as 'sortable', the table records can be sorted by the model column's values
  # by clicking the corresponding table column header. The table records will be ordered by the order of the
  # query passed to build_table_state until a sort is applied to them by clicking a table column header.
  # Note that sortable columns with custom renderers will sort by their underlying attribute.
  #
  # Search, sort, and pagination run on the server, orchestrated by the IndexTable controller helper.
  # Results are swapped using Turbo frames so a full page reload is not triggered.
  #
  # Setting up a table requires three steps:
  #   1. Model: declare searchable and sortable columns (the model must include Queryable).
  #        class Camp < ApplicationRecord
  #          include Queryable
  #          searchable_by :name, :description
  #          sortable_by :name, :description
  #        end
  #
  #   2. Controller: build the table state from a query using build_table_state (the controller must include IndexTable)
  #        include IndexTable
  #        def index = (@table_state = build_table_state(Camp.all, param_scope: :camps))
  #
  #   3. View: render the component, declaring columns via the block.
  #        <%= render Shared::IndexTableComponent.new(
  #              state: @table_state,
  #              path_builder: ->(params) { camps_path(params) }) do |table| %>
  #          <% table.column :name %>
  #          <% table.column :description %>
  #          <% table.column :active do |camp| %>
  #            <%= camp.active? ? "Active" : "Inactive" %>
  #          <% end %>
  #        <% end %>
  #
  # `param_scope:` namespaces the table's query params (q, order_by, order, page)
  # under a key. Used to prevent collisions when a page has multiple tables.
  #
  # `path_builder:` is a lambda that takes a params hash and returns the path to visit
  # to get the filtered, sorted, and paginated data
  #
  # Searching can be disabled using `searchable: false`.
  class IndexTableComponent < ViewComponent::Base
    include Turbo::FramesHelper

    attr_accessor :state, :path_builder, :searchable, :columns

    delegate :records, :current_page, :total_pages, :query_params, :param_scope, to: :state

    Column = Data.define(:attribute, :header, :col_size, :cell_renderer)

    def initialize(state:, path_builder:, searchable: true)
      super()
      @state = state
      @path_builder = path_builder
      @searchable = searchable
      @columns = []
    end

    def column(attribute, header: nil, col_size: nil, &cell_renderer)
      @columns << Column.new(
        attribute: attribute,
        header: header || default_header_for(attribute),
        col_size: col_size,
        cell_renderer: cell_renderer
      )
    end

    private

    def frame_id
      "#{param_scope || model_class.model_name.plural}_index_table"
    end

    def sortable?(column) = model_class.sortable_columns.include?(column.attribute.to_s)

    def next_dir(column)
      attr = column.attribute.to_s

      if query_params.order_by == attr && query_params.order == "asc"
        "desc"
      else
        "asc"
      end
    end

    def path_with(**overrides)
      new_params = query_params.to_h.merge(overrides).compact
      nested_params = param_scope ? { param_scope => new_params } : new_params

      path_builder.call(nested_params)
    end

    def path
      path_with
    end

    def path_with_page(page_number)
      path_with(page: page_number.clamp(1, total_pages))
    end

    def path_with_sort(column)
      path_with(order_by: column.attribute, order: next_dir(column), page: 1)
    end

    def render_cell_content(record, column)
      if column.cell_renderer
        view_context.capture(record, &column.cell_renderer)
      else
        record.public_send(column.attribute)
      end
    end

    def column_sizes = columns.map { |c| c.col_size || "minmax(0, 1fr)" }.join(" ")

    def model_class
      # memoize to only have to compute value once per table
      return @model_class if instance_variable_defined?(:@model_class)

      @model_class = if records.respond_to?(:model)
                       records.model
                     elsif records.respond_to?(:klass)
                       records.klass
                     end
    end

    def default_header_for(attribute)
      klass = model_class

      if klass.respond_to?(:human_attribute_name)
        klass.human_attribute_name(attribute)
      else
        attribute.to_s.humanize
      end
    end

    def before_render
      content
    end
  end
end
