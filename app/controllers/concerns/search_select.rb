module SearchSelect
  extend ActiveSupport::Concern

  SelectState = Data.define(:records, :query, :selected_ids, :param_scope)

  # q: query, selected: selected ids
  def build_search_select_state(query, param_scope: nil, limit: 10)
    scoped_params = param_scope ? params[param_scope] : params
    keyed_params = scoped_params.is_a?(ActionController::Parameters) ? scoped_params : ActionController::Parameters.new

    SelectState.new(
      records: query.search(keyed_params[:q]).order(query.primary_key).limit(limit),
      query: keyed_params[:q],
      selected_ids: Array(keyed_params[:selected]).map(&:to_s),
      param_scope: param_scope
    )
  end

  def self.frame_id_for(model_class, param_scope = nil)
    "#{param_scope || model_class.model_name.plural}_search_select"
  end
end
