# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Migration do
  @moduledoc """
  Some migrations helpers
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Migration

      def add_foreign_key(key, table, opts \\ [null: false]) do
        add(
          key,
          references(table, type: :bigint, on_update: :update_all, on_delete: :delete_all, column: :local_id),
          opts
        )
      end

      def add_foreign_key_nilify(key, table, opts \\ []) do
        add(
          key,
          references(table, type: :bigint, on_update: :update_all, on_delete: :nilify_all),
          opts
        )
      end

      def create_counter_trigger(counter_field, counter_table, counter_id_field, trigger_table, trigger_id_field) do
        execute("""
        CREATE FUNCTION update_#{counter_table}_#{counter_field}()
        RETURNS trigger AS $$
        BEGIN
          IF (TG_OP = 'INSERT') THEN
            UPDATE #{counter_table} SET #{counter_field} = #{counter_field} + 1
              WHERE #{counter_id_field} = NEW.#{trigger_id_field};
            RETURN NEW;
          ELSIF (TG_OP = 'DELETE') THEN
            UPDATE #{counter_table} SET #{counter_field} = #{counter_field} - 1
              WHERE #{counter_id_field} = OLD.#{trigger_id_field};
            RETURN OLD;
          END IF;
          RETURN NULL;
        END;
        $$ LANGUAGE plpgsql;
        """)

        execute("DROP TRIGGER IF EXISTS update_#{counter_table}_#{counter_field}_trg ON #{trigger_table};")

        execute("""
        CREATE TRIGGER update_#{counter_table}_#{counter_field}_trg
        AFTER INSERT OR DELETE
        ON #{trigger_table}
        FOR EACH ROW
        EXECUTE PROCEDURE update_#{counter_table}_#{counter_field}();
        """)
      end

      def destroy_counter_trigger(counter_field, counter_table, trigger_table) do
        execute("DROP TRIGGER IF EXISTS update_#{counter_table}_#{counter_field}_trg ON #{trigger_table};")
        execute("DROP FUNCTION IF EXISTS update_#{counter_table}_#{counter_field}();")
      end
    end
  end
end
