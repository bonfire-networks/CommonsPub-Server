defmodule ValueFlows.Migrations do

    def change do
        ValueFlows.Measurement.Migrations.change()
    end
    
end