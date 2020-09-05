defmodule CommonsPub.Locales.Country.ServiceTest do
  # use ExUnit.Case, async: true

  # import ExUnit.Assertions
  # alias CommonsPub.Repo
  # alias CommonsPub.Locales.{Country, CountryService, Country.Error.NotFound}

  # @countries [
  #   {"nl", "Netherlands", "Nederland"}
  # ]
  # @expected_country_codes Enum.sort(Enum.map(@countries, fn {x,_,_} -> x end))

  # describe "CommonsPub.Locales.Country.Service" do

  #   setup do
  #     :ok = Ecto.Adapters.SQL.Sandbox.checkout(CommonsPub.Repo)
  #     {:ok, %{}}
  #   end

  #   test "is fetching from good source data" do
  #     in_db = Repo.all(Country)
  #     |> Enum.map(&(&1.iso_code2))
  #     |> Enum.sort()
  #     assert @expected_country_codes == in_db
  #   end

  #   @bad_country_codes ["fizz", "buzz bazz"]

  #   test "returns results consistent with the source data" do
  #     # the database will be our source of truth
  #     countries = Repo.all(Country)
  #     assert Enum.count(countries) == Enum.count(@expected_country_codes)
  #     # Every db entry must match up to our module metadata
  #     for {code, name, nom} <- countries do
  # 	lang = CountryService.lookup!(code)
  # 	assert %{id: id, english_name: designation, local_name: naam} = lang
  # 	assert id == code
  # 	assert name == designation
  # 	assert nom == naam
  # 	assert id == CountryService.lookup_id!(code)
  #     end

  #     for c <- @bad_country_codes do
  # 	assert {:error, %Country.Error.NotFound{id: c}} ==
  # 	  CountryService.lookup(c)
  # 	assert %Country.Error.NotFound{id: c} ==
  # 	  catch_throw(CountryService.lookup!(c))
  #     end
  #   end
  # end
end
