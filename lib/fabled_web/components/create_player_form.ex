defmodule FabledWeb.CreatePlayerForm do
  use FabledWeb, :html

  attr :action, :string, required: true
  attr :form, Phoenix.HTML.Form, required: true
  attr :button_text, :string, required: true

  def create_player_form(assigns) do
    ~H"""
    <.form for={@form} action={@action}>
      <.input type="text" field={@form[:player_name]} placeholder="Your name" />
      <button><%= @button_text %></button>
    </.form>
    """
  end
end
