defmodule FabledWeb.GameLive do
  use FabledWeb, :live_view

  alias Fabled.Lobby

  def mount(%{"lobby" => lobbyId}, session, socket) do
    case Lobby.fetch(lobbyId) do
      :error ->
        {:ok, push_navigate(socket, to: ~p"/")}

      {:ok, lobby} ->
        {:ok, player} = Lobby.fetch_player(lobby, session["player_id"])

        socket =
          socket
          |> assign(lobby: lobby)
          |> assign(player: player)

        {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    You are in lobby <%= @lobby.id %> as <%= @player.name %>
    <br /> Players:
    <ul>
      <%= for player <- @lobby.players do %>
        <li><%= player.name %></li>
      <% end %>
    </ul>
    Owner is <span><%= @lobby.owner.name %></span>
    """
  end
end
