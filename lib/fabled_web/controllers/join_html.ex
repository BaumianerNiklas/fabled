defmodule FabledWeb.JoinHTML do
  use FabledWeb, :html

  def invite(assigns) do
    ~H"""
    You are joining lobby <%= @lobby.id %>
    <.form for={@form} action={~p"/join/?lobby=#{@lobby.id}&player_name=#{@form[:player_name]}"}>
      <.input type="text" field={@form[:player_name]} placeholder="your name" />
      <button>join</button>
    </.form>
    """
  end
end
