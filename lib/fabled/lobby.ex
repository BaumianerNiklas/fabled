defmodule Fabled.Lobby do
  @enforce_keys [:id]
  defstruct [:id]

  @type t :: %__MODULE__{
    id: String.t()
  }

  @spec new() :: t()
  def new() do
    if :ets.info(:lobbies) == :undefined do
      :ets.new(:lobbies, [:set, :protected, :named_table])
    end

    id = Nanoid.generate()
    lobby = %__MODULE__{id: id}

    :ets.insert(:lobbies, {id, lobby})
    
    lobby
  end
end
