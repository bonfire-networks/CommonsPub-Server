defmodule ValueFlows.Migrations do

    def change do
        ValueFlows.Geolocation.Migrations.change()
    end
    
end