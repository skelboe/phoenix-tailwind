defmodule MyApp.ContextCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias MyApp.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import MyApp.Factory

      import MyApp.ContextCase, only: [test_context: 2]
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyApp.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, {:shared, self()})
    end

    :ok
  end

  defmacro test_context(module, do: block) do
    quote do
      @context unquote(module)

      import MyApp.ContextCase, only: [assert_resource: 1, assert_resource: 2]
      unquote(block)
    end
  end

  defmacro assert_resource(module, opts \\ []) do
    quote do
      @module unquote(module)
      @singular MyApp.ContextCase.singular(@module)
      @plural MyApp.ContextCase.plural(@module)
      @factory unquote(opts[:factory])

      test "#{@singular} is a module" do
        assert {:module, _} = Code.ensure_compiled(@module), "#{@module} has not been defined"
      end

      test "#{@singular} exposes a changeset" do
        assert function_exported?(@module, :changeset, 2),
               "#{@module} does not define changeset/2"
      end

      test "list_#{@plural}/0 returns all #{@plural}" do
        %{id: id} = insert(@factory)
        assert [%{id: ^id}] = apply(@context, :"list_#{@plural}", [])
      end

      test "get_#{@singular}!/1 returns the #{@singular} with given id" do
        %{id: id} = insert(@factory)
        assert %{id: ^id} = apply(@context, :"get_#{@singular}", [id])
      end

      test "create_#{@singular}/1 with valid data creates a #{@singular}" do
        attrs = params_for(@factory)
        assert {:ok, rec} = apply(@context, :"create_#{@singular}", [attrs])

        for {key, val} <- attrs do
          assert val == Map.get(rec, key)
        end
      end

      test "create_#{@singular}/1 with invalid data" do
        attrs = invalid_params_for(@factory)
        assert {:error, %Ecto.Changeset{}} = apply(@context, :"create_#{@singular}", [attrs])
      end

      test "update_#{@singular}/1 with valid data updates a #{@singular}" do
        record = insert(@factory)
        attrs = update_params_for(@factory)

        assert {:ok, rec} = apply(@context, :"update_#{@singular}", [record, attrs])

        for {key, val} <- attrs do
          assert val == Map.get(rec, key)
        end
      end

      test "update_#{@singular}/1 with invalid data" do
        record = insert(@factory)
        attrs = invalid_params_for(@factory)

        assert {:error, %Ecto.Changeset{}} =
                 apply(@context, :"update_#{@singular}", [record, attrs])
      end

      test "delete_#{@singular}/1 deletes the #{@singular}" do
        record = %{id: id} = insert(@factory)
        assert {:ok, %{id: ^id}} = apply(@context, :"delete_#{@singular}", [record])

        assert_raise Ecto.NoResultsError, fn ->
          apply(@context, :"get_#{@singular}!", [id])
        end
      end

      test "change_#{@singular}/1 returns a #{@singular} changeset" do
        record = insert(@factory)
        assert %Ecto.Changeset{} = apply(@context, :"change_#{@singular}", [record])
      end
    end
  end

  @doc false
  def singular(module) do
    module
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> String.downcase()
    |> Inflex.singularize()
  end

  @doc false
  def plural(module) do
    module
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> String.downcase()
    |> Inflex.pluralize()
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
