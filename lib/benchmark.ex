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
    require IEx
    require HTTPoison
    require Poison
    
    HTTPoison.start

    
    communes_origins = ["LAS CONDES"]
    {:ok, communes_response} = HTTPoison.get("http://localhost:5000/api/communes")
    {:ok, communes_destinies} = Poison.decode(communes_response.body)
    {:ok, cbos_response} = HTTPoison.get("http://localhost:9001/api/couriers_branch_offices")
    {:ok, courier_branch_offices_availables} = Poison.decode(cbos_response.body)
    {:ok, couriers_response} = HTTPoison.get("http://localhost:9001/api/couriers")
    {:ok, couriers_availables} = Poison.decode(couriers_response.body)
    heights = Enum.to_list(1..90)
    lengths = Enum.to_list(1..90)
    widths = Enum.to_list(1..90)
    weights = Enum.to_list(1..50)
    
    destiny_sample = Enum.random communes_destinies
    destinies_available_for_couriers = 
      Enum.reject(destiny_sample["couriers_availables"], fn {k, v} -> v == "" end)
        |> Enum.into(%{})
    
    origins_available_for_couriers = 
      Enum.map(couriers_availables, fn courier -> {String.downcase(courier["name"]), "LAS CONDES"} end)
        |> Enum.into(%{})

    IEx.pry
    algorithm_selected = if Enum.random(Enum.to_list(1..100)) < 90, do: 1, else: 2
    algorithm_days = if algorithm_selected == 1, do: "", else: Enum.random(Enum.to_list(2..7))
    courier_selected = if Enum.random(Enum.to_list(1..100)) < 92, do: false, else: true

    
    courier_for_client = if courier_selected, do: couriers_availables.sample, else: nil
    courier_branch_office_id = if courier_selected, do: "courier_branch_offices_availables.where(courier_id: courier_for_client.id).sample.try(:id)", else: nil


    params = [
      couriers_availables_from: origins_available_for_couriers,
      couriers_availables_to: {},
      height: Enum.random(heights),
      length: Enum.random(lengths),
      width: Enum.random(widths),
      weight: Enum.random(weights),
      is_payable: (if Enum.random(Enum.to_list(1..100)) < 92, do: false, else: true),
      destiny: (if Enum.random(Enum.to_list(1..100)) < 90, do: "domicilio", else: "sucursal"),
      courier_branch_office_id: courier_branch_office_id,
      courier_for_client: (if courier_for_client != nil, do: String.downcase(courier_for_client["name"]), else: nil),
      courier_selected: courier_selected,
      commune_id: destiny_sample["id"],
      algorithm: algorithm_selected,
      algorithm_days: algorithm_days
    ]

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
