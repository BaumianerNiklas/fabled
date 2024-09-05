defmodule Fabled.Player do
  @enforce_keys [:id, :name]
  defstruct [:id, :name]

  @type t() :: %__MODULE__{
    id: String.t(),
    name: String.t(),
  }

  @spec new(String.t()) :: t()
  def new(name) do
    id = Nanoid.generate()

    %__MODULE__{
      id: id,
      name: name,
    }
  end
end
