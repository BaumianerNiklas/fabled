defmodule Fabled.Lobby do
  @moduledoc """
  A GenServer that stores data about the current lobbies
  and provides an interface for working with them.
  """

  use GenServer
  alias Fabled.Player

  @enforce_keys [:id, :owner]
  defstruct [:id, :owner, players: []]

  @type t :: %__MODULE__{
          id: String.t(),
          players: [Player.t()],
          owner: Player.t()
        }

  ### Client Code
  # Interface the client uses to work with lobbies

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
end
