defmodule TictacWeb.LiveView.Components do
  @moduledoc """
  Collection of components for rendering game elements.
  """
  use Phoenix.HTML
  alias Tictac.GameState
  alias Tictac.Player
  alias Tictac.Square

  def player_tile_color(%GameState{status: :done} = game, player) do
    case GameState.result(game) |> IO.inspect(label: "RESULT") do
      :draw ->
        "gray"

      # If the winner is this player
      ^player ->
        "green"

      # If the losing player
      %Player{} ->
        "red"

      _else ->
        "gray"
    end
  end

  def player_tile_color(%GameState{status: :playing} = game, player) do
    if GameState.player_turn?(game, player) do
      "green"
    else
      "gray"
    end
  end

  # When we don't have the game state yet (haven't upgraded page to LiveView)
  def square(player, game, square_name, opts \\ [])

  def square(%Player{} = player, %GameState{status: :done} = game, square_name, opts) do
    # TODO: If game state is :done, color the winning colors according to the player. If this player won, color winning squares green. If opponent won, color them red.

    # Get the local player's opponent for coloring
    opponent = GameState.opponent(game, player)
    IO.inspect(opponent, label: "OPPONENT")

    winning_squares =
      case GameState.check_for_player_win(game, player) do
        :not_found -> []
        [_, _, _] = winning_spaces -> winning_spaces
      end

    losing_squares =
      case GameState.check_for_player_win(game, opponent) do
        :not_found -> []
        [_, _, _] = losing_spaces -> losing_spaces
      end

    IO.inspect(winning_squares, label: "WINNING BY")
    IO.inspect(losing_squares, label: "LOSING BY")

    # TODO: If game state is playing, color is black (or dark gray)
    # color =
    #   case game do
    #     %Game{status: :done} ->
    #     %Game{} -> "black"
    #   end

    color =
      cond do
        Enum.member?(winning_squares, square_name) -> "bg-green-200"
        Enum.member?(losing_squares, square_name) -> "bg-red-200"
        true -> "bg-white"
      end

    case GameState.find_square(game, square_name) do
      {:ok, sq} ->
        render_square(sq.letter, color, opts)

      _not_found ->
        render_square(nil, "bg-white", opts)
    end
  end

  def square(%Player{} = player, %GameState{} = game, square_name, opts) do
    # TODO: If game state is :done, color the winning colors according to the player. If this player won, color winning squares green. If opponent won, color them red.

    # TODO: If game state is playing, color is black (or dark gray)
    # color =
    #   case game do
    #     %Game{status: :done} ->
    #     %Game{} -> "black"
    #   end

    case GameState.find_square(game, square_name) do
      {:ok, %Square{} = square} ->
        render_square(square.letter, "bg-white", opts)

      _not_found ->
        render_square(nil, "bg-white", opts)
    end
  end

  def square(_player, _game, _square_name, _opts), do: nil

  def render_square(letter, color, opts) do
    classes = "m-4 w-full h-22 rounded-lg shadow #{color} cursor-pointer"

    Phoenix.HTML.Tag.content_tag :span, Keyword.merge(opts, class: classes) do
      case letter do
        nil ->
          Phoenix.HTML.raw({:safe, "&nbsp;"})

        letter ->
          letter
      end
    end
  end

  def result(%GameState{status: :done} = state) do
    text =
      case GameState.result(state) do
        :draw ->
          "Tie Game!"

        %Player{name: winner_name} ->
          "#{winner_name} Wins!"
      end

    ~E"""
    <div class="m-8 text-6xl text-center text-green-700">
      <%= text %>
    </div>
    """
  end

  def result(%GameState{} = _state) do
    ~E"""
    """
  end
end