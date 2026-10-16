require "test_helper"

class IndexTableTest < ActiveSupport::TestCase
  class Harness
    include IndexTable

    attr_reader :params

    def initialize(params) = @params = params
  end

  def build_harness_state(relation, params: {}, **opts)
    Harness.new(ActionController::Parameters.new(params)).build_table_state(relation, **opts)
  end

  test "it paginates and computes totals before limiting" do
    create_list(:camp, 10)
    state = build_harness_state(Camp.all, per_page: 5)

    assert_equal 5, state.records.to_a.size
    assert_equal 1, state.current_page
    assert_operator state.total_pages, :>=, 2
  end

  test "it clamps an out-of-range page to the last page" do
    create_list(:camp, 5)
    state = build_harness_state(Camp.all, params: { page: "999" }, per_page: 10)
    assert_equal state.total_pages, state.current_page
  end

  test "it reads the correct scoped params when param_scope is given" do
    camp = create(:camp)
    state = build_harness_state(Camp.all, params: { camps: { q: camp.name } }, param_scope: :camps)

    assert_includes state.records, camp
    assert_equal camp.name, state.query_params.q
  end

  test "it raises ArgumentError when per_page is not positive" do
    [0, -5].each do |per_page|
      assert_raises(ArgumentError) do
        build_harness_state(Camp.all, per_page: per_page)
      end
    end
  end

  test "it degrades gracefully when the scoped param is not a hash" do
    create_list(:camp, 3)

    ["test", ["test"]].each do |malformed|
      state = build_harness_state(Camp.all, params: { camps: malformed }, param_scope: :camps)

      assert_equal 3, state.total_count
      assert_nil state.query_params.q
    end
  end
end
