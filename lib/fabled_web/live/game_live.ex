defmodule FabledWeb.GameLive do
  use FabledWeb, :live_view

  import FabledWeb.LobbyComponents
  import FabledWeb.GameComponents

  # for the is_game_active/1 guard
  require Fabled.Lobby
  alias Fabled.Lobby

  def mount(%{"lobby_id" => lobby_id}, session, socket) do
    if connected?(socket) do
      Fabled.subscribe("lobby:" <> lobby_id, session["player_id"])
    end

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
              |> assign(players: lobby.players |> Enum.reverse())
              |> assign(invite_link: Lobby.invite_link(lobby.id))
              |> assign(lobby_owner?: Lobby.owner?(lobby, player))
              |> assign(game_active?: Lobby.is_game_active(lobby))
              |> assign(round: lobby.round)

            {:ok, socket}
        end
    end
  end

  def render(assigns) do
    ~H"""
    <%= unless @game_active? do %>
      <.lobby_screen
        lobby={@lobby}
        player={@player}
        players={@players}
        invite_link={@invite_link}
        lobby_owner?={@lobby_owner?}
      />
    <% else %>
      <.game lobby={@lobby} />
    <% end %>
    """
  end

  def handle_event("copied_invite_link", _params, socket),
    do: {:noreply, put_flash(socket, :info, "Copied invite link to clipboard!")}

  def handle_event("start_game", _params, socket) do
    lobby =
      Lobby.start_game(socket.assigns.lobby)
      |> IO.inspect()

    socket = assign(socket, lobby: lobby)

    # {:noreply, push_patch(socket, to: ~p"/game/#{socket.assigns.lobby.id}/1")}
    {:noreply, socket}
  end

  def handle_event("done", %{"input" => text}, socket) do
    lobby =
      Lobby.player_done_with_round(socket.assigns.lobby, socket.assigns.player, text)
      |> dbg()

    socket = assign(socket, lobby: lobby)

    {:noreply, socket}
  end

  def handle_params(%{"round" => round}, _uri, socket) do
    {round, _rest} = Integer.parse(round)
    socket = assign(socket, round: round)
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  def handle_info(:game_started, socket) do
    {:ok, lobby} = Lobby.fetch(socket.assigns.lobby.id)

    socket =
      socket
      |> assign(lobby: lobby)
      |> assign(round: lobby.round)
      |> assign(game_active?: true)

    {:noreply, socket}
  end

  def handle_info({:player_joined, player}, socket) do
    # refetch lobby to ensure we are synced with the server
    {:ok, lobby} = Lobby.fetch(socket.assigns.lobby.id)

    socket =
      socket
      |> update(:players, fn players -> players ++ [player] end)
      |> assign(lobby: lobby)

    {:noreply, socket}
  end

  def handle_info({:player_done_with_round, lobby}, socket) do
    {:noreply, assign(socket, lobby: lobby)}
  end

  def handle_info({:round_ended, lobby}, socket) do
    socket =
      socket
      |> assign(lobby: lobby)
      |> assign(round: :results)

    {:noreply, socket}
  end
end
