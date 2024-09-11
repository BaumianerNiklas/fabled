defmodule FabledWeb.CreateHTML do
  use FabledWeb, :html
  import FabledWeb.CreatePlayerForm

  def index(assigns) do
    ~H"""
    <.create_player_form
      form={@form}
      action={~p"/create?player_name=#{@form[:player_name]}"}
      button_text="Create Lobby"
    />
    """
  end
end
