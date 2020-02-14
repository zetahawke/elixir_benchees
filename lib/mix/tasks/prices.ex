defmodule Mix.Tasks.Prices do
  use Mix.Task

  @shortdoc "Simply calls the Hello.say/0 function."
  def run(_) do
    # calling our Hello.say() function from earlier
    Benchmark.some_fun_stuff()
  end
end