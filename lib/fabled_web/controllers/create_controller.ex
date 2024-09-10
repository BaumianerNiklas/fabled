defmodule FabledWeb.CreateController do
  use FabledWeb, :controller
  alias Fabled.{Lobby, Player}

  # The home page at /
  def index(conn, _params) do
    conn
    |> assign(:form, Phoenix.Component.to_form(%{player_name: nil}))
    |> render(:index)
  end

  # Create a new lobby and redirect to it
  def create(conn, %{"player_name" => player_name}) do
    player = Player.new(player_name)
    lobby = Lobby.new(player) |> Lobby.add_player(player)

    conn
    |> put_session(:player_id, player.id)
    |> redirect(to: ~p"/game/#{lobby.id}")
  end
end
