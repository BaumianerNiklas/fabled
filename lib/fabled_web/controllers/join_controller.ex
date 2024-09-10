defmodule FabledWeb.JoinController do
  use FabledWeb, :controller

  alias Fabled.Lobby
  alias Fabled.Player

  def join(conn, %{"player_name" => player_name, "lobby" => lobby_id}) do
    # This is usually called after joining a lobby via invite link

    player = Player.new(player_name)
    # TODO: handle error case
    {:ok, lobby} = Lobby.fetch(lobby_id)

    Lobby.add_player(lobby, player)

    Fabled.broadcast("lobby:" <> lobby_id, {:player_joined, player})

    conn
    |> put_session(:player_id, player.id)
    |> redirect(to: ~p"/game?lobby=#{lobby_id}")
  end

  def join(conn, %{"lobby" => lobby_id}) do
    # This action handles invite links
    {:ok, lobby} = Lobby.fetch(lobby_id)

    form = Phoenix.Component.to_form(%{"player_name" => nil})

    conn
    |> assign(:lobby, lobby)
    |> assign(:form, form)
    |> render(:invite)
  end

  def join(conn, _params) do
    # When no other route matches, i.e. no lobby is provided,
    # just redirect to the homepage
    redirect(conn, to: ~p"/")
  end
end
