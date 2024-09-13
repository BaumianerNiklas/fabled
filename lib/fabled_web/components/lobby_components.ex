defmodule FabledWeb.LobbyComponents do
  use FabledWeb, :html

  alias Fabled.Lobby
  alias Fabled.Player

  attr :lobby, Lobby, required: true
  attr :player, Player, required: true
  attr :players, :list, required: true
  attr :invite_link, :string, required: true
  attr :lobby_owner?, :boolean, default: false

  def lobby_screen(assigns) do
    ~H"""
    You are in lobby <%= @lobby.id %> as <%= @player.name %>
    <br /> Players:
    <ul>
      <%= for player <- @players do %>
        <li><%= player.name %></li>
      <% end %>
    </ul>
    <p>Owner is <%= @lobby.owner.name %></p>
    <p>
      Invite link:
      <button phx-click={
        JS.dispatch("fabled:copy_to_clipboard", detail: @invite_link)
        |> JS.push("copied_invite_link")
      }>
        <pre><%= @invite_link %></pre>
      </button>
    </p>

    <button disabled={not @lobby_owner?} phx-click="start_game">
      Start Game!
    </button>
    """
  end
end
