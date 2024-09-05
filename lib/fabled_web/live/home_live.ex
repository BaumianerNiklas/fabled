defmodule FabledWeb.HomeLive do
  use FabledWeb, :live_view

  alias Fabled.Lobby

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, lobby: nil)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <button phx-click="create_lobby"> hit me up with a new lobby </button>
    <%= if @lobby != nil do %>
    <%= @lobby.id %>
    <% end %>
    """
  end

  @impl true
  def handle_event("create_lobby", _params, socket) do
    IO.puts("we received a click ayooo")

    lobby = Lobby.new()

    socket = assign(socket, lobby: lobby)

    {:noreply, socket}
  end
end
