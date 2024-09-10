defmodule Fabled do
  @moduledoc """
  Fabled keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Phoenix.PubSub
  alias Fabled.Lobby

  def subscribe("lobby:" <> lobby_id = topic, player_id) do
    if Lobby.has_player?(lobby_id, player_id) do
      PubSub.subscribe(Fabled.PubSub, topic)
    else
      {:error, "Player not in Lobby"}
    end
  end

  def broadcast("lobby:" <> lobby_id = topic, {:player_joined, player} = message) do
    if Lobby.has_player?(lobby_id, player.id) do
      PubSub.broadcast(Fabled.PubSub, topic, message)
    else
      {:error, "Player not in Lobby"}
    end
  end
end
