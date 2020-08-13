defmodule CommonsPub.Locales do
  @moduledoc """
  Functions for localising the application.

  Though we have chosen to call this module the more familiar name of
  "localisation", technically, it would more accurately be called
  "Globalisation", a composite of:

  * Localisation (l10n)
  * Internationalisation (i18n)
  """

  alias CommonsPub.Locales.{CountryService, LanguageService}

  defdelegate languages(), to: LanguageService, as: :list_all

  defdelegate countries(), to: CountryService, as: :list_all

  defdelegate language(code), to: LanguageService, as: :lookup

  defdelegate language!(code), to: LanguageService, as: :lookup!

  defdelegate country(code), to: CountryService, as: :lookup

  defdelegate country!(code), to: CountryService, as: :lookup!
end
