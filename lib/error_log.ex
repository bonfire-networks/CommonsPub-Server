defmodule ErrorLog do
    use Blunder.Absinthe.ErrorHandler
    require Logger
  
    @impl Blunder.Absinthe.ErrorHandler
    def call(blunder) do
      Logger.error blunder.message
    end
  
    @impl Blunder.Absinthe.ErrorHandler
    def call(blunder, any) do
      Logger.error blunder.message
    end
  
  end