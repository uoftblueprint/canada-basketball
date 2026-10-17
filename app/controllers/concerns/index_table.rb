module IndexTable
  extend ActiveSupport::Concern

  TableState = Data.define(:records, :current_page, :total_pages, :total_count, :param_scope, :query_params)
  QueryParams = Data.define(:q, :order_by, :order)

  def build_table_state(query, per_page: 10, param_scope: nil)
    raise ArgumentError, "per_page must be positive, got #{per_page}" unless per_page.positive?

    scoped_params = param_scope ? params[param_scope] : params
    keyed_params = scoped_params.is_a?(ActionController::Parameters) ? scoped_params : ActionController::Parameters.new

    query = query
            .search(keyed_params[:q])
            .ordered_by(keyed_params[:order_by], keyed_params[:order])

    total_count = query.count
    total_pages = [(total_count.to_f / per_page).ceil, 1].max
    current_page = keyed_params[:page].to_i.clamp(1, total_pages)

    records = query.limit(per_page).offset((current_page - 1) * per_page)

    TableState.new(
      records: records,
      current_page: current_page,
      total_pages: total_pages,
      total_count: total_count,
      param_scope: param_scope,
      query_params: QueryParams.new(
        q: keyed_params[:q],
        order_by: keyed_params[:order_by],
        order: keyed_params[:order]
      )
    )
  end
end
