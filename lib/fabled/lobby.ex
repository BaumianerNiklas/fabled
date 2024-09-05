defmodule Fabled.Lobby do
  @moduledoc """
  A GenServer that stores data about the current lobbies
  and provides an interface for working with them.
  """

  use GenServer
  alias Fabled.Player

  @enforce_keys [:id]
  defstruct [:id, players: []]

  @type t :: %__MODULE__{
    id: String.t(),
    players: [Player.t()]
  }

  ### Client Code
  # Interface the client uses to work with lobbies

  @spec new() :: t()
  def new() do
    GenServer.call(__MODULE__, :new)
  end

  @spec add_player(t(), Player.t()) :: t()
  def add_player(lobby, player) do
    GenServer.call(__MODULE__, {:add_player, lobby, player})
  end

  @spec fetch(String.t()) :: {:ok, t()} | :error
  def fetch(lobbyId) do
    GenServer.call(__MODULE__, {:fetch, lobbyId})
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
  def handle_call(:new, _from, table) do
    id = Nanoid.generate()
    lobby = %__MODULE__{id: id}

    true = :ets.insert(table, {id, lobby})

    {:reply, lobby, table}
  end

  @impl true
  def handle_call({:fetch, lobbyId}, _from, table) do
    case :ets.lookup(:lobbies, lobbyId) do
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
end
