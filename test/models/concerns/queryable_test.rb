require "test_helper"

class QueryableTest < ActiveSupport::TestCase
  test "searchable_columns is the included searchable columns intersected with the database columns" do
    assert_equal %w[name description], Camp.searchable_columns
  end

  test "search matches an included column, case-insensitively" do
    match = create(:camp, name: "Toronto Camp")
    other = create(:camp, name: "Montreal Camp")

    results = Camp.search("toronto")
    assert_includes results, match
    assert_not_includes results, other
  end

  test "search escapes LIKE wildcards" do
    match = create(:camp, name: "100%")
    other = create(:camp, name: "99")

    results = Camp.search("100%")
    assert_includes results, match
    assert_not_includes results, other
  end

  test "search returns all records if the search query is blank" do
    assert_equal Camp.pluck(:id).sort, Camp.search("").pluck(:id).sort
  end

  test "sortable_columns is the included sortable columns intersected with the database columns" do
    assert_equal %w[name description], Camp.sortable_columns
  end

  test "ordered_by sorts records correctly" do
    a = create(:camp, name: "AAA")
    z = create(:camp, name: "ZZZ")
    ordered = Camp.where(id: [a.id, z.id]).ordered_by("name", "desc")
    assert_equal [z, a], ordered.to_a
  end

  test "ordered_by rejects unknown columns without raising or SQL injection" do
    assert_nothing_raised { Camp.ordered_by("name; DROP TABLE camps", "asc").to_a }
  end

  test "ordered_by ignores a real column that is not sortable and falls back to default order" do
    first = create(:camp)
    second = create(:camp)

    first.update(updated_at: 2.days.ago)
    second.update(updated_at: 1.day.ago)

    ordered = Camp.where(id: [first.id, second.id]).ordered_by("updated_at", "desc")

    assert_equal [first, second], ordered.to_a
  end
end
