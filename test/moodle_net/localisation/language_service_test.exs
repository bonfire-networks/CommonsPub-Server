defmodule CommonsPub.Locales.Language.ServiceTest do
  # use ExUnit.Case, async: true

  # import ExUnit.Assertions
  # alias MoodleNet.Repo
  # alias CommonsPub.Locales.{Language, LanguageService, Language.Error.NotFound}

  # @languages [
  #   {"en", "English", "English"}
  # ]
  # @expected_language_codes Enum.sort(Enum.map(@languages, fn {x,_,_} -> x end))
  # describe "CommonsPub.Locales.Language.Service" do

  #   setup do
  #     :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)
  #     {:ok, %{}}
  #   end

  #   test "is fetching from good source data" do
  #     in_db = Repo.all(Language)
  #     |> Enum.map(&(&1.iso_code2))
  #     |> Enum.sort()
  #     assert @expected_language_codes == in_db
  #   end

  #   @bad_language_codes ["fizz", "buzz bazz"]

  #   test "returns results consistent with the source data" do
  #     # the database will be our source of truth
  #     languages = Repo.all(Language)
  #     assert Enum.count(languages) == Enum.count(@expected_language_codes)
  #     # Every db entry must match up to our module metadata
  #     for {code, name, nom} <- languages do
  # 	lang = LanguageServer.lookup!(code)
  # 	assert %{id: id, english_name: designation, local_name: naam} = lang
  # 	assert id == code
  # 	assert name == designation
  # 	assert nom == naam
  # 	assert id == LanguageService.lookup_id!(code)
  #     end

  #     for l <- @bad_language_codes do
  # 	assert {:error, %Language.Error.NotFound{id: l}} ==
  # 	  LanguageService.lookup(l)
  # 	assert %Language.Error.NotFound{id: l} ==
  # 	  catch_throw(LanguageService.lookup!(l))
  #     end
  #   end
  # end
end
