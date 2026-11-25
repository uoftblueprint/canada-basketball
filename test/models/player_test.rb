require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  test "requires a name" do
    player = build(:player, name: nil)

    assert_not player.valid?
    assert_includes player.errors[:name], "can't be blank"
  end

  test "cannot be destroyed while it has game events" do
    game = create(:game)
    player = create(:player)
    create(:camp_registration, camp: game.camp, player: player, team: game.team)
    create(:game_event, game: game, player: player, kind: :two_point_made)

    assert_not player.destroy
    assert_includes player.errors[:base], "Cannot delete record because dependent game events exist"
  end

  test "factory builds a valid player" do
    assert build(:player).valid?
  end

  test "profile fields are optional" do
    player = build(:player, birth_year: nil, height_cm: nil, province: nil, hometown: nil)

    assert player.valid?
  end

  test "birth_year must be between 1900 and the current year" do
    assert build(:player, birth_year: 1900).valid?
    assert build(:player, birth_year: Date.current.year).valid?

    [1899, Date.current.year + 1].each do |year|
      player = build(:player, birth_year: year)
      assert_not player.valid?, "expected #{year} to be invalid"
      assert player.errors.key?(:birth_year)
    end
  end

  test "birth_year must be an integer" do
    player = build(:player, birth_year: 2000.5)

    assert_not player.valid?
    assert_includes player.errors[:birth_year], "must be an integer"
  end

  test "height_cm must be greater than 50 and less than 300" do
    assert build(:player, height_cm: 51).valid?
    assert build(:player, height_cm: 299).valid?

    [50, 300].each do |height|
      player = build(:player, height_cm: height)
      assert_not player.valid?, "expected #{height} to be invalid"
    end
  end

  test "province must be a Canadian province or territory code" do
    player = build(:player, province: "XX")

    assert_not player.valid?
    assert_includes player.errors[:province], "is not included in the list"
  end

  test "blank province and hometown are stored as nil" do
    player = create(:player, province: "", hometown: "  ")

    assert_nil player.reload.province
    assert_nil player.hometown
  end

  test "hometown is stripped" do
    assert_equal "Toronto", build(:player, hometown: "  Toronto ").hometown
  end

  test "province_name translates the province code" do
    assert_equal "Ontario", build(:player, province: "ON").province_name
    assert_nil build(:player, province: nil).province_name
  end

  test "database rejects values that bypass validations" do
    player = create(:player)

    { birth_year: 1800, height_cm: 300, province: "XX" }.each do |column, value|
      assert_raises(ActiveRecord::StatementInvalid, "expected #{column}=#{value.inspect} to be rejected") do
        player.update_column(column, value) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end

  test "search matches name and hometown" do
    by_name = create(:player, name: "Andrew Wiggins", hometown: "Toronto")
    by_hometown = create(:player, name: "Jamal Murray", hometown: "Kitchener")
    create(:player, name: "Someone Else", hometown: "Calgary")

    assert_equal [by_name], Player.search("wiggins").to_a
    assert_equal [by_hometown], Player.search("kitch").to_a
  end

  test "new profile fields are sortable" do
    assert_equal %w[name birth_year height_cm province hometown].sort, Player.sortable_columns.sort

    tall = create(:player, height_cm: 210)
    short = create(:player, height_cm: 160)

    assert_equal [short, tall], Player.ordered_by(:height_cm, :asc).to_a
    assert_equal [tall, short], Player.ordered_by(:height_cm, :desc).to_a
  end
end
