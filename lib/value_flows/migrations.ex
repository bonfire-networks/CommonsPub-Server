defmodule ValueFlows.Migrations do

    def change do
        ValueFlows.Measurement.Migrations.change()
    end

    def change_measure do
        ValueFlows.Measurement.Migrations.change_measure()
    end


end
