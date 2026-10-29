class PlayersController < ApplicationController
  before_action :require_admin, only: %i[new edit create update destroy]

  def index
    @players = Player.order(:name)
  end

  def show
    @player = Player.find(params.expect(:id))
  end

  def new
    @player = Player.new
  end

  def edit
    @player = Player.find(params.expect(:id))
  end

  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to players_path, flash: { success: "Player created successfully" }, status: :see_other
    else
      flash.now[:error] = @player.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def update
    @player = Player.find(params.expect(:id))

    if @player.update(player_params)
      redirect_to player_path(@player), flash: { success: "Player updated successfully" }, status: :see_other
    else
      flash.now[:error] = @player.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    player = Player.find(params.expect(:id))
    if player.destroy
      redirect_to players_path, flash: { success: "Player deleted successfully" }, status: :see_other
    else
      redirect_back_or_to players_path, flash: { error: player.errors.full_messages.to_sentence }, status: :see_other
    end
  end

  private

  def player_params
    params.expect(player: [:name])
  end
end
