defmodule FabledWeb.JoinHTML do
  use FabledWeb, :html
  import FabledWeb.CreatePlayerForm

  def invite(assigns) do
    ~H"""
    You are joining lobby <%= @lobby.id %>
    <.create_player_form
      form={@form}
      action={~p"/join/?lobby=#{@lobby.id}&player_name=#{@form[:player_name]}"}
      button_text="Join Lobby"
    />
    """
  end
end
