defmodule MyApp.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Minutes.Repo

  ## Helpers

  def invalid_params_for(factory) do
    for {key, _} <- params_for(factory) do
      {key, nil}
    end
    |> Map.new()
  end

  def update_params_for(factory) do
    for {key, val} <- params_for(factory) do
      update =
        cond do
          String.contains?(to_string(key), "_id") -> val
          is_binary(val) -> String.reverse(val)
          is_integer(val) -> val + 1
          is_float(val) -> val + 0.1
          true -> val
        end

      {key, update}
    end
    |> Map.new()
  end
end
