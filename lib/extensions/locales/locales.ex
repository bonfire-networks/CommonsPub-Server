defmodule CommonsPub.Locales do
  @moduledoc """
  Functions for handling thing like:
  - languages
  - dialects (TODO)
  - countries
  - timezones (TODO)
  - currencies (TODO)
  """

  alias CommonsPub.Locales.Language
  alias CommonsPub.Locales.Country

  defdelegate languages(), to: Language.Service, as: :list_all

  defdelegate countries(), to: Country.Service, as: :list_all

  defdelegate language(code), to: Language.Service, as: :lookup

  defdelegate language!(code), to: Language.Service, as: :lookup!

  defdelegate country(code), to: Country.Service, as: :lookup

  defdelegate country!(code), to: Country.Service, as: :lookup!
end
