defmodule Fabled.Lobby do
  @moduledoc """
  A GenServer that stores data about the current lobbies
  and provides an interface for working with them.
  """

  use GenServer
  alias Fabled.Player

  @enforce_keys [:id, :owner]
  defstruct [:id, :owner, players: [], round: -1, stories: %{}]

  @type t :: %__MODULE__{
          id: String.t(),
          players: [Player.t()],
          owner: Player.t()
        }

  ### Client Code
  # Interface the client uses to work with lobbies

  defguard is_game_active(lobby) when lobby.round >= 0

  @spec new(Player.t()) :: t()
  def new(creator) do
    GenServer.call(__MODULE__, {:new, creator})
  end

  @spec add_player(t(), Player.t()) :: t()
  def add_player(lobby, player) do
    GenServer.call(__MODULE__, {:add_player, lobby, player})
  end

  @spec fetch(String.t()) :: {:ok, t()} | :error
  def fetch(lobby_id) do
    GenServer.call(__MODULE__, {:fetch, lobby_id})
  end

  @spec fetch_player(t(), String.t()) :: {:ok, Player.t()} | :error
  def fetch_player(lobby, player_id) do
    GenServer.call(__MODULE__, {:fetch_player, lobby, player_id})
  end

  @doc """
  Starts the game in this lobby only if it has not yet started already.
  Broadcasts the :game_started message to the corresponding lobby.
  """
  def start_game(lobby) when not is_game_active(lobby) do
    GenServer.call(__MODULE__, {:start_game, lobby})
  end

  def player_done_with_round(lobby, player, text) when is_game_active(lobby) do
    lobby = GenServer.call(__MODULE__, {:player_done_with_round, lobby, player, text})

    if everyone_ready?(lobby) do
      end_round(lobby)
    end

    lobby
  end

  def end_round(lobby) do
    GenServer.call(__MODULE__, {:end_round, lobby})
  end

  def has_player?(lobby_id, player_id) do
    with {:ok, lobby} <- fetch(lobby_id),
         {:ok, _} <- fetch_player(lobby, player_id) do
      true
    else
      :error -> false
    end
  end

  def owner?(lobby, player), do: lobby.owner.id == player.id

  # TODO: change depending on environment (dev/prod)
  def invite_link(lobby_id), do: "http://localhost:4000/join?lobby=#{lobby_id}"

  # TODO: make this actually work for rounds past the first
  def everyone_ready?(lobby) do
    Enum.all?(lobby.stories, fn {_, story} -> Enum.count(story) > 0 end)
  end

  ### GenServer Implementation
  # Handles access to the ETS tables

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init([]) do
    table = :ets.new(:lobbies, [:set, :protected, :named_table])
    {:ok, table}
  end

  @impl true
  def handle_call({:new, creator}, _from, table) do
    id = Nanoid.generate()

    lobby = %__MODULE__{
      id: id,
      owner: creator
    }

    true = :ets.insert(table, {id, lobby})

    {:reply, lobby, table}
  end

  @impl true
  def handle_call({:fetch, lobby_id}, _from, table) do
    case :ets.lookup(:lobbies, lobby_id) do
      [] -> {:reply, :error, table}
      [{_id, lobby} | _rest] -> {:reply, {:ok, lobby}, table}
    end
  end

  @impl true
  def handle_call({:add_player, lobby, player}, _from, table) do
    lobby = Map.update(lobby, :players, [player], fn prev -> [player | prev] end)

    # insert/2 replaces old values if key already exists.
    true = :ets.insert(table, {lobby.id, lobby})

    {:reply, lobby, table}
  end

  @impl true
  def handle_call({:fetch_player, lobby, player_id}, _from, table) do
    [{_id, lobby} | _rest] = :ets.lookup(table, lobby.id)

    case Enum.find(lobby.players, &(&1.id == player_id)) do
      nil -> {:reply, :error, table}
      player -> {:reply, {:ok, player}, table}
    end
  end

  @impl true
  def handle_call({:start_game, lobby}, _from, table) do
    player_ids = Enum.map(lobby.players, & &1.id)
    stories = for id <- player_ids, into: %{}, do: {id, []}

    lobby =
      lobby
      |> Map.put(:round, 0)
      |> Map.put(:stories, stories)

    true = :ets.insert(table, {lobby.id, lobby})

    Fabled.broadcast_to_lobby(lobby.id, :game_started)

    {:reply, lobby, table}
  end

  @impl true
  def handle_call({:player_done_with_round, lobby, player, text}, _from, table) do
    lobby =
      Map.update!(lobby, :stories, fn stories ->
        Map.update!(stories, player.id, fn story -> [text | story] end)
      end)

    true = :ets.insert(table, {lobby.id, lobby})

    Fabled.broadcast_to_lobby(lobby.id, {:player_done_with_round, lobby})

    {:reply, lobby, table}
  end

  @impl true
  def handle_call({:end_round, lobby}, _from, table) do
    lobby = Map.put(lobby, :round, :results)

    true = :ets.insert(table, {lobby.id, lobby})

    Fabled.broadcast_to_lobby(lobby.id, {:round_ended, lobby})

    {:reply, lobby, table}
  end
end
