defmodule FabledWeb.GameLive do
  use FabledWeb, :live_view

  alias Fabled.Lobby

  def mount(%{"lobby" => lobby_id}, session, socket) do
    case Lobby.fetch(lobby_id) do
      :error ->
        socket =
          socket
          |> put_flash(
            :error,
            "You tried joining a lobby that does not exist or is already over."
          )
          |> push_navigate(to: ~p"/")

        {:ok, socket}

      {:ok, lobby} ->
        case Lobby.fetch_player(lobby, session["player_id"]) do
          # When player is not already known, just redirect to the invite link page
          # where they can give themselves a name and join the lobby
          :error ->
            socket = push_navigate(socket, to: ~p"/join?lobby=#{lobby.id}")
            {:ok, socket}

          {:ok, player} ->
            socket =
              socket
              |> assign(lobby: lobby)
              |> assign(player: player)

            {:ok, socket}
        end
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
