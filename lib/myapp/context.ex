defmodule MyApp.Context do
  @moduledoc """
  Module for building ecto contexts
  """
  import Inflex, only: [singularize: 1, pluralize: 1]

  @doc false
  defmacro __using__(opts \\ []) do
    quote do
      @repo unquote(opts[:repo] || throw("Repo has not been assigned"))
      import MyApp.Context, only: [resource: 1, resource: 2]
    end
  end

  @doc """
  Define a resource.

  ## Examples

      resource MyApp.Project
      resource MyApp.Project, only: [:read]
      resource MyApp.Project, only: [:read, :write]
      resource MyApp.Project, only: [:list, :get, :change]

  """
  defmacro resource(schema, opts \\ []) do
    quote do
      alias MyApp.Context

      @only Keyword.get(unquote(opts), :only, [
              :list,
              :get,
              :get_by,
              :create,
              :update,
              :delete,
              :change
            ])

      if Enum.member?(@only, :list) || Enum.member?(@only, :read) do
        Context.define(:list, unquote(schema))
      end

      if Enum.member?(@only, :get) || Enum.member?(@only, :read) do
        Context.define(:get, unquote(schema))
        Context.define(:get_by, unquote(schema))
      end

      if Enum.member?(@only, :create) || Enum.member?(@only, :write) do
        Context.define(:create, unquote(schema))
      end

      if Enum.member?(@only, :update) || Enum.member?(@only, :write) do
        Context.define(:update, unquote(schema))
      end

      if Enum.member?(@only, :delete) || Enum.member?(@only, :write) do
        Context.define(:delete, unquote(schema))
      end

      if Enum.member?(@only, :change) || Enum.member?(@only, :write) do
        Context.define(:change, unquote(schema))
      end
    end
  end

  @doc false
  defmacro define(:list, schema) do
    quote do
      def unquote(:"list_#{plural(schema)}")(opts \\ []) do
        unquote(schema)
        |> @repo.all()
        |> @repo.preload(Keyword.get(opts, :preload, []))
      end
    end
  end

  @doc false
  defmacro define(:get, schema) do
    quote do
      def unquote(:"get_#{singular(schema)}")(id, opts \\ []) do
        unquote(schema)
        |> @repo.get(id)
        |> @repo.preload(Keyword.get(opts, :preload, []))
      end

      def unquote(:"get_#{singular(schema)}!")(id, opts \\ []) do
        unquote(schema)
        |> @repo.get!(id)
        |> @repo.preload(Keyword.get(opts, :preload, []))
      end
    end
  end

  @doc false
  defmacro define(:get_by, schema) do
    quote do
      def unquote(:"get_#{singular(schema)}_by")(clauses, opts \\ []) do
        unquote(schema)
        |> @repo.get_by(clauses)
        |> @repo.preload(Keyword.get(opts, :preload, []))
      end

      def unquote(:"get_#{singular(schema)}_by!")(clauses, opts \\ []) do
        unquote(schema)
        |> @repo.get_by!(clauses)
        |> @repo.preload(Keyword.get(opts, :preload, []))
      end
    end
  end

  @doc false
  defmacro define(:create, schema) do
    quote do
      def unquote(:"create_#{singular(schema)}")(attrs, opts \\ []) do
        %unquote(schema){}
        |> unquote(schema).changeset(attrs)
        |> @repo.insert()
      end

      def unquote(:"create_#{singular(schema)}!")(attrs, opts \\ []) do
        %unquote(schema){}
        |> unquote(schema).changeset(attrs)
        |> @repo.insert!()
      end
    end
  end

  @doc false
  defmacro define(:update, schema) do
    quote do
      def unquote(:"update_#{singular(schema)}")(struct, attrs \\ %{}, opts \\ []) do
        struct
        |> unquote(schema).changeset(attrs)
        |> @repo.update()
      end

      def unquote(:"update_#{singular(schema)}!")(struct, attrs \\ %{}, opts \\ []) do
        struct
        |> unquote(schema).changeset(attrs)
        |> @repo.update!()
      end
    end
  end

  @doc false
  defmacro define(:delete, schema) do
    quote do
      def unquote(:"delete_#{singular(schema)}")(struct, opts \\ []) do
        @repo.delete(struct)
      end

      def unquote(:"delete_#{singular(schema)}!")(struct, opts \\ []) do
        @repo.delete!(struct)
      end
    end
  end

  @doc false
  defmacro define(:change, schema) do
    quote do
      def unquote(:"change_#{singular(schema)}")(struct, attrs \\ %{}, opts \\ []) do
        unquote(schema).changeset(struct, attrs)
      end
    end
  end

  @doc false
  def singular(module) do
    module
    |> module_name()
    |> singularize()
  end

  @doc false
  def plural(module) do
    module
    |> module_name()
    |> pluralize()
  end

  def module_name({_, _, module}) do
    module
    |> List.last()
    |> to_string()
    |> String.downcase()
  end
end
