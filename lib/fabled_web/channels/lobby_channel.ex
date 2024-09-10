defmodule FabledWeb.LobbyChannel do
  use FabledWeb, :channel

  alias Fabled.Lobby

  @impl true
  def join("lobby:" <> lobby_id, payload, socket) do
    IO.inspect("joining chcannel")
    IO.inspect(payload, label: "payload")

    case Lobby.fetch(lobby_id) do
      :error -> {:error, %{reason: "no such lobby"}}
      # TODO: check if player is in lobby
      _lobby -> {:ok, socket}
    end

    {:error, %{reason: "lol no"}}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (lobby:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end
end
