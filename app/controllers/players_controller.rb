class PlayersController < ApplicationController
  include SearchSelect
  include IndexTable

  before_action :require_admin, only: %i[search new edit create update destroy]

  def index
    @table_state = build_table_state(
      Player.order(:name)
    )
  end

  def search
    state = build_search_select_state(Player.all)
    render SearchSelectInput::SuggestionsComponent.new(
      state:,
      value_method: :id,
      text_method: :name
    ), layout: false
  end

  def show
    @player = Player.includes(camp_registrations: %i[camp team]).find(params.expect(:id))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @player = Player.new

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    @player = Player.find(params.expect(:id))
  end

  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to players_path, flash: { success: t(".success") }, status: :see_other
    else
      flash.now[:error] = @player.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def update
    @player = Player.find(params.expect(:id))

    if @player.update(player_params)
      redirect_to player_path(@player), flash: { success: t(".success") }, status: :see_other
    else
      flash.now[:error] = @player.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    player = Player.find(params.expect(:id))
    if player.destroy
      redirect_to players_path, flash: { success: t(".success") }, status: :see_other
    else
      redirect_back_or_to players_path, flash: { error: player.errors.full_messages.to_sentence }, status: :see_other
    end
  end

  private

  def player_params
    params.expect(player: [:name])
  end
end
