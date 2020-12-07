# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.ValueCalculation.ValueCalculations do
  alias CommonsPub.{Common, Repo}
  alias CommonsPub.Users.User

  alias ValueFlows.ValueCalculation

  def create(%User{} = user, attrs) do
    Repo.insert(ValueCalculation.create_changeset(user, attrs))
  end

  def update(%ValueCalculation{} = calculation, attrs) do
    Repo.update(ValueCalculation.update_changeset(calculation, attrs))
  end

  def soft_delete(%ValueCalculation{} = calculation) do
    Common.Deletion.soft_delete(calculation)
  end
end
