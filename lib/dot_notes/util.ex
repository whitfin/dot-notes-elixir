defmodule DotNotes.Util do
  @moduledoc """
  Utility module to hold any common utilities and macros.
  """

  @doc """
  Determines whether a value is a valid haystack or not.

  This just shorthands a check on being either a Map or a List.
  """
  @spec is_haystack(value :: any) :: true | false
  defmacro is_haystack(value) do
    quote do
      is_map(unquote(value)) or is_list(unquote(value))
    end
  end

end
