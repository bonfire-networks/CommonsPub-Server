defmodule MoodleNet.Localisation do
  @moduledoc """
  Functions for localising the application.

  Though we have chosen to call this module the more familiar name of "localisation",
  technically, it would more accurately be called "Globalisation", which is a composite of:
  * Localisation (l10n)
  * Internationalisation (i18n)
  """

  alias MoodleNet.Localisation.{CountryService, LanguageService}

  defdelegate language(code), to: LanguageService, as: :lookup
  defdelegate country(code), to: CountryService, as: :lookup
  defdelegate language!(code), to: LanguageService, as: :lookup!
  defdelegate country!(code), to: CountryService, as: :lookup!
  
end
