defmodule FabledWeb.LobbyComponents do
  use FabledWeb, :html

  alias Fabled.Lobby

  attr :lobby, Lobby, required: true

  def game(assigns) do
    form = Phoenix.Component.to_form(%{"input" => nil})
    assigns = assign(assigns, :game_form, form)

    ~H"""
    <%= unless @lobby.round == :results do %>
      <.form for={@game_form} phx-submit="done">
        <.input type="text" field={@game_form[:input]} autocomplete="off" />
        <button>Done!</button>
      </.form>
    <% else %>
      <div :for={{player_id, story} <- @lobby.stories} class="border-red border-solid border-2 mt-2">
        <% {:ok, player} = Lobby.fetch_player(@lobby, player_id) %>
        <p>Story from <%= player.name %>:</p>
        <ul>
          <li :for={text <- story}><%= text %></li>
        </ul>
      </div>
    <% end %>
    """
  end
end
