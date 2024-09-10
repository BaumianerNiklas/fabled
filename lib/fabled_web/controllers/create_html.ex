defmodule FabledWeb.CreateHTML do
  use FabledWeb, :html

  def index(assigns) do
    ~H"""
    <.form for={@form} action={~p"/create?player_name=#{@form[:player_name]}"}>
      <.input type="text" field={@form[:player_name]} placeholder="your name" />
      <button>Create new Lobby</button>
    </.form>
    """
  end
end
