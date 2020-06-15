defmodule Liquid do
  @timeout 5_000

  def render_template(name, template, context \\ %{}, extra_options \\ []),
    do: GenServer.call(name, {:render_template, template, context, extra_options}, @timeout)

  def parse_template(name, source, presets \\ %{}, extra_options \\ []),
    do: GenServer.call(name, {:parse_template, source, presets, extra_options}, @timeout)

  def register_file_system(name, module, path),
    do: GenServer.cast(name, {:register_file_system, module, path})

  def clear_registers(name), do: GenServer.cast(name, {:clear_registers})

  def clear_extra_tags(name), do: clear_registers(name)

  def register_tags(name, tag_name, module, type),
    do: GenServer.cast(name, {:register_tags, tag_name, module, type})

  def registers(name), do: GenServer.call(name, {:registers}, @timeout)

  def registers_lookup(name, tag_name, extra_options \\ []),
    do: GenServer.call(name, {:registers_lookup, tag_name, extra_options}, @timeout)

  def add_filters(name, filter_module), do: GenServer.cast(name, {:add_filters, filter_module})

  def read_template_file(name, path, extra_options \\ []),
    do: GenServer.call(name, {:read_template_file, path, extra_options}, @timeout)

  def full_path(name, path, extra_options \\ []),
    do: GenServer.call(name, {:full_path, path, extra_options}, @timeout)

  @compile {:inline, argument_separator: 0}
  @compile {:inline, filter_argument_separator: 0}
  @compile {:inline, filter_quoted_string: 0}
  @compile {:inline, filter_quoted_fragment: 0}
  @compile {:inline, filter_arguments: 0}
  @compile {:inline, single_quote: 0}
  @compile {:inline, double_quote: 0}
  @compile {:inline, quote_matcher: 0}
  @compile {:inline, variable_start: 0}
  @compile {:inline, variable_end: 0}
  @compile {:inline, variable_incomplete_end: 0}
  @compile {:inline, tag_start: 0}
  @compile {:inline, tag_end: 0}
  @compile {:inline, any_starting_tag: 0}
  @compile {:inline, invalid_expression: 0}
  @compile {:inline, tokenizer: 0}
  @compile {:inline, parser: 0}
  @compile {:inline, template_parser: 0}
  @compile {:inline, partial_template_parser: 0}
  @compile {:inline, quoted_string: 0}
  @compile {:inline, quoted_fragment: 0}
  @compile {:inline, tag_attributes: 0}
  @compile {:inline, variable_parser: 0}
  @compile {:inline, filter_parser: 0}

  def argument_separator, do: ","
  def filter_argument_separator, do: ":"
  def filter_quoted_string, do: "\"[^\"]*\"|'[^']*'"

  def filter_quoted_fragment,
    do: "#{filter_quoted_string()}|(?:[^\s,\|'\":]|#{filter_quoted_string()})+"

  # (?::|,)\s*((?:\w+\s*\:\s*)?"[^"]*"|'[^']*'|(?:[^ ,|'":]|"[^":]*"|'[^':]*')+):?\s*((?:\w+\s*\:\s*)?"[^"]*"|'[^']*'|(?:[^ ,|'":]|"[^":]*"|'[^':]*')+)?
  def filter_arguments,
    do:
      ~r/(?:#{filter_argument_separator()}|#{argument_separator()})\s*((?:\w+\s*\:\s*)?#{
        filter_quoted_fragment()
      }):?\s*(#{filter_quoted_fragment()})?/

  def single_quote, do: "'"
  def double_quote, do: "\""
  def quote_matcher, do: ~r/#{single_quote()}|#{double_quote()}/

  def variable_start, do: "{{"
  def variable_end, do: "}}"
  def variable_incomplete_end, do: "\}\}?"

  def tag_start, do: "{%"
  def tag_end, do: "%}"

  def any_starting_tag, do: "(){{()|(){%()"

  def invalid_expression,
    do: ~r/^{%.*}}$|^{{.*%}$|^{%.*([^}%]}|[^}%])$|^{{.*([^}%]}|[^}%])$|(^{{|^{%)/ms

  def tokenizer,
    do: ~r/()#{tag_start()}.*?#{tag_end()}()|()#{variable_start()}.*?#{variable_end()}()/

  def parser,
    do:
      ~r/#{tag_start()}\s*(?<tag>.*?)\s*#{tag_end()}|#{variable_start()}\s*(?<variable>.*?)\s*#{
        variable_end()
      }/ms

  def template_parser, do: ~r/#{partial_template_parser()}|#{any_starting_tag()}/ms

  def partial_template_parser,
    do: "()#{tag_start()}.*?#{tag_end()}()|()#{variable_start()}.*?#{variable_incomplete_end()}()"

  def quoted_string, do: "\"[^\"]*\"|'[^']*'"
  def quoted_fragment, do: "#{quoted_string()}|(?:[^\s,\|'\"]|#{quoted_string()})+"

  def tag_attributes, do: ~r/(\w+)\s*\:\s*(#{quoted_fragment()})/
  def variable_parser, do: ~r/\[[^\]]+\]|[\w\-]+/
  def filter_parser, do: ~r/(?:\||(?:\s*(?!(?:\|))(?:#{quoted_fragment()}|\S+)\s*)+)/

  defp ensure_unused(name) do
    case GenServer.whereis(name) do
      nil -> {:ok, true}
      pid -> {:error, {:already_started, pid}}
    end
  end

  defmodule List do
    def even_elements([_, h | t]) do
      [h] ++ even_elements(t)
    end

    def even_elements([]), do: []
  end

  defmodule Atomizer do
    def to_existing_atom(string) do
      try do
        String.to_existing_atom(string)
      rescue
        ArgumentError -> nil
      end
    end
  end
end
