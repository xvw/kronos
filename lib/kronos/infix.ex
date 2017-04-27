defmodule Kronos.Infix do 

  @moduledoc """
  This module is a shortcut to import `Mizur.Infix` functions.
  """

  defmacro __using__(opts) do 
    quote do 
      use(Mizur.Infix, unquote(opts))
    end
  end

end
