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
    heights = Enum.to_list(1..70)
    lengths = Enum.to_list(1..70)
    widths = Enum.to_list(1..70)
    weights = Enum.to_list(1..25)

    build_params = fn ->
      destiny_sample = Enum.random communes_destinies

      destinies_available_for_couriers = 
        Enum.reject(destiny_sample["couriers_availables"], fn {k, v} -> v == "" end)
          |> Enum.into(%{})
      
      origins_available_for_couriers = 
        Enum.map(couriers_availables, fn courier -> {String.downcase(courier["name"]), "LAS CONDES"} end)
          |> Enum.into(%{})

      algorithm_selected = if Enum.random(Enum.to_list(1..100)) < 92, do: 1, else: 2
      algorithm_days = if algorithm_selected == 1, do: "", else: Enum.random(Enum.to_list(2..7))
      courier_selected = if Enum.random(Enum.to_list(1..100)) < 92, do: false, else: true
      couriers_for_destiny = couriers_availables |> Enum.filter(fn courier -> Enum.member?(Enum.map(origins_available_for_couriers, fn {k,v} -> k end), String.downcase(courier["name"])) end)
      courier_for_client = if courier_selected, do: couriers_for_destiny |> Enum.random, else: nil
      # preselected_cbo = get_in(courier_branch_offices_availables |> Enum.filter(fn cbo -> cbo["courier_id"] == courier_for_client["id"] end), [Enum.random, "id"])
      # courier_branch_office_id = if courier_selected, do: preselected_cbo, else: nil

      [
        couriers_availables_from: origins_available_for_couriers, #Enum.map(origins_available_for_couriers, fn({key, value}) -> {String.to_atom(key), value} end),
        couriers_availables_to: destinies_available_for_couriers, #Enum.map(destinies_available_for_couriers, fn({key, value}) -> {String.to_atom(key), value} end),
        height: Enum.random(heights),
        length: Enum.random(lengths),
        width: Enum.random(widths),
        weight: Enum.random(weights),
        is_payable: (if Enum.random(Enum.to_list(1..100)) < 92, do: false, else: true),
        destiny: (if Enum.random(Enum.to_list(1..100)) < 90, do: "domicilio", else: "sucursal"),
        courier_branch_office_id: nil,#courier_branch_office_id,
        courier_for_client: (if courier_for_client != nil, do: String.downcase(courier_for_client["name"]), else: nil),
        courier_selected: courier_selected,
        commune_id: destiny_sample["id"],
        algorithm: algorithm_selected,
        algorithm_days: algorithm_days
      ]
      # IEx.pry
    end

    # IEx.pry
    
    Benchee.run(%{
      "old_algorithm api"    => fn(list) -> 
        url = "http://localhost:6000/api/prices"
        headers = %{"Content-Type" => "application/json"}

        HTTPoison.post(url, build_params.() |> Enum.into(%{}) |> Poison.encode |> (fn {:ok, body} -> body end).(), headers)
      end,
      "new_algorithm api" => fn(list) -> 
        url = "http://localhost:6000/api/quotations"
        headers = %{"Content-Type" => "application/json"}
        
        HTTPoison.post(url, build_params.() |> Enum.into(%{}) |> Poison.encode |> (fn {:ok, body} -> body end).(), headers)
      end
    },
      formatters: [
        {Benchee.Formatters.HTML, file: "samples_output/my.html"},
        Benchee.Formatters.Console
      ],
      time: 2,
      warmup: 2,
      inputs: %{
        "Smaller List" => Enum.to_list(1..50),
        "Bigger List"  => Enum.to_list(1..300),
      }
    )
  end
end
