defmodule Benchmark do
  @moduledoc """
  Documentation for `Benchmark`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Benchmark.hello()
      :world

  """
  def hello do
    :world
  end

  def some_fun_stuff do
    Benchee.run(%{
      "old_algorithm api"    => fn(list) -> 
        url = "http://localhost:6000/api/prices"
        headers = []

        response = HTTPoison.get(url, headers, params: params)
        Poison.decode(response.body)
      end,
      "new_algorithm api" => fn(list) -> 
        url = "http://localhost:6000/api/quotations"
        headers = []

        response = HTTPoison.get(url, headers, params: params)
        Poison.decode(response.body)
      end
    },
      formatters: [
        {Benchee.Formatters.HTML, file: "samples_output/my.html"},
        Benchee.Formatters.Console
      ],
      time: 10,
      warmup: 2,
      inputs: %{
        "Smaller List" => Enum.to_list(1..100),
        "Bigger List"  => Enum.to_list(1..2_000),
      }
    )
  end
end
