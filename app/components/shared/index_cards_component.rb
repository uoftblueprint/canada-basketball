module Shared
  # Renders a searchable and paginated grid of records.
  #
  # The render block receives the component and declares how each record is
  # rendered as a card by calling `card` with a block. That inner block is
  # stored and invoked once per record, mirroring how IndexTableComponent
  # handles column cell renderers.
  #
  #   <%= render Shared::IndexCardsComponent.new(
  #         state: @table_state,
  #         path_builder: ->(params) { camps_path(params) }) do |cards| %>
  #     <% cards.card do |camp| %>
  #       <%= render Camps::CardComponent.new(camp: camp) %>
  #     <% end %>
  #   <% end %>
  #
  # `param_scope:` on the state namespaces the query params (q, page) so that
  # multiple index components on one page don't collide.
  #
  # `path_builder:` is a lambda that takes a params hash and returns the path
  # to visit to get the filtered and paginated data.
  #
  # Searching can be disabled using `searchable: false`.
  class IndexCardsComponent < ViewComponent::Base
    include Turbo::FramesHelper

    delegate :records, :current_page, :total_pages, :query_params, :param_scope, to: :state

    def initialize(
      state:,
      path_builder:,
      searchable: true,
      search_label: nil,
      search_placeholder: nil,
      listings_label: nil,
      pagination_label: nil
    )
      super()
      @state = state
      @path_builder = path_builder
      @searchable = searchable
      @search_label = search_label
      @search_placeholder = search_placeholder
      @listings_label = listings_label
      @pagination_label = pagination_label
      @card_renderer = nil
    end

    def card(&card_renderer)
      @card_renderer = card_renderer
    end

    private

    attr_reader :state, :path_builder, :searchable, :card_renderer

    def search_placeholder
      @search_placeholder || t("shared.index_cards_component.search_placeholder")
    end

    def search_label
      @search_label || t("shared.index_cards_component.search_label")
    end

    def listings_label
      @listings_label || t("shared.index_cards_component.listings_label")
    end

    def pagination_label
      @pagination_label || t("shared.index_cards_component.pagination_label")
    end

    def previous_page_label
      t("shared.index_cards_component.previous_page")
    end

    def next_page_label
      t("shared.index_cards_component.next_page")
    end

    def frame_id
      "#{param_scope || 'index'}_index_cards"
    end

    def path_with(**overrides)
      new_params = query_params.to_h.except(:order_by, :order).merge(overrides).compact
      nested_params = param_scope ? { param_scope => new_params } : new_params

      path_builder.call(nested_params)
    end

    def path
      path_with
    end

    def path_with_page(page_number)
      path_with(page: page_number.clamp(1, total_pages))
    end

    def render_card(record)
      raise ArgumentError, "IndexCardsComponent requires a `card` block" unless card_renderer

      view_context.capture(record, &card_renderer)
    end

    # Runs the render block once, before the template renders, so it can
    # register the card renderer via `card`.
    def before_render
      content
    end
  end
end
