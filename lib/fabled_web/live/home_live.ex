defmodule FabledWeb.HomeLive do
  use FabledWeb, :live_view

  alias Fabled.Lobby
  alias Fabled.Player

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(lobby: nil)
      |> assign(form: to_form(%{"player_name" => nil}))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.form for={@form} phx-submit="create_lobby">
      <.input type="text" field={@form[:player_name]} placeholder="your name" />
      <button>Create new Lobby</button>
    </.form>
    """
  end

  @impl true
  def handle_event("create_lobby", %{"player_name" => name}, socket) do
    player = Player.new(name)
    lobby = Lobby.new(player) |> Lobby.add_player(player)

    IO.inspect(socket)

    socket =
      socket
      |> push_navigate(to: ~p"/join?lobby=#{lobby.id}&player=#{player.id}")

    {:noreply, socket}
  end
end
