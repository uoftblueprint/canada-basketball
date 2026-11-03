require "test_helper"

class DefaultFormBuilderTest < ActionView::TestCase
  setup do
    @form = DefaultFormBuilder.new(:camp, Camp.new, view, {})
  end

  test "text_field applies the default classes" do
    assert_includes @form.text_field(:name), "input h-13 w-full"
  end

  test "text_field lets a passed class replace a default" do
    html = @form.text_field(:name, class: "w-1/2")

    assert_includes html, "w-1/2"
    assert_not_includes html, "w-full"
  end

  test "text_field accepts a conditional class hash" do
    html = @form.text_field(:name, class: { "w-1/2" => true, "hidden" => false })

    assert_includes html, "w-1/2"
    assert_not_includes html, "hidden"
  end

  test "submit applies the default classes when only options are passed" do
    assert_includes @form.submit(data: { turbo: false }), "btn btn-primary"
  end

  test "label applies the default classes when only options are passed" do
    assert_includes @form.label(:name, id: "name-label"), "label mb-2"
  end

  test "check_box applies the same classes as checkbox" do
    assert_includes @form.check_box(:active), "checkbox border-base-300"
  end

  test "collection_check_boxes applies the checkbox classes" do
    html = @form.collection_check_boxes(:player_ids, [create(:player)], :id, :name)

    assert_includes html, "checkbox border-base-300"
  end

  test "forms inside view components use the default builder" do
    render Players::FormComponent.new(player: Player.new)

    assert_select "input[type=text].h-13"
  end
end
