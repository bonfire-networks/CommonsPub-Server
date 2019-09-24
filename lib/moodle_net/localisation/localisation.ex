defmodule MoodleNet.Localisation do

  alias MoodleNet.Localisation.{CountryService, LanguageService}

  defdelegate fetch_language(code), to: LanguageService, as: :lookup
  defdelegate fetch_country(code), to: CountryService, as: :lookup
  defdelegate fetch_language!(code), to: LanguageService, as: :lookup!
  defdelegate fetch_country!(code), to: CountryService, as: :lookup!
  
end
