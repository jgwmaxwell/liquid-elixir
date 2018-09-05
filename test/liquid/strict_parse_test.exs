defmodule Liquid.StrictParseTest do
  use ExUnit.Case

  alias Liquid.Template

  test "error on empty filter" do
    assert_syntax_error("{{|test}}")
    assert_syntax_error("{{test |a|b|}}")
  end

  test "meaningless parens error" do
    markup = "a == 'foo' or (b == 'bar' and c == 'baz') or false"
    assert_syntax_error("{% if #{markup} %} YES {% endif %}")
  end

  test "unexpected characters syntax error" do
    markup = "true && false"
    assert_syntax_error("{% if #{markup} %} YES {% endif %}")
  end

  test "incomplete close variable" do
    assert_syntax_error("TEST {{method}")
  end

  test "incomplete close tag" do
    assert_syntax_error("TEST {% tag }")
  end

  test "open tag without close" do
    assert_syntax_error("TEST {%")
  end

  test "open variable without close" do
    assert_syntax_error("TEST {{")
  end

  test "syntax error" do
    template = "{{ 16  | divided_by: 0 }}"

    assert "Liquid error: divided by 0" ==
             template |> Template.parse() |> Template.render() |> elem(1)
  end

  test "missing endtag parse time error" do
    assert_raise RuntimeError,
                 "Invalid tag name for,The tag block is malformed or you are using a reserved tag name to define a Custom Tag",
                 fn ->
                   Template.parse("{% for a in b %} ...")
                 end
  end

  test "unrecognized operator" do
    assert_raise RuntimeError,
                 "Invalid tag name if,The tag block is malformed or you are using a reserved tag name to define a Custom Tag",
                 fn ->
                   Template.parse("{% if 1 =! 2 %}ok{% endif %}")
                 end

    assert_raise RuntimeError, "expected string \"{%\"", fn ->
      Template.parse("{{%%%}}")
    end
  end

  defp assert_syntax_error(markup) do
    assert_raise(RuntimeError, fn -> Template.parse(markup) end)
  end
end
