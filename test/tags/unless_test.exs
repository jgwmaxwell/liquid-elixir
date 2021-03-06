Code.require_file("../../test_helper.exs", __ENV__.file)

defmodule Liquid.UnlessTest do
  use ExUnit.Case

  setup do
    start_supervised!({Liquid.Process, [name: :liquid]})
    :ok
  end

  test :test_unless do
    assert_template_result(
      "  ",
      " {% unless true %} this text should not go into the output {% endunless %} "
    )

    assert_template_result(
      "  this text should go into the output  ",
      " {% unless false %} this text should go into the output {% endunless %} "
    )

    assert_template_result(
      "  you rock ?",
      "{% unless true %} you suck {% endunless %} {% unless false %} you rock {% endunless %}?"
    )
  end

  test :test_unless_else do
    assert_template_result(" YES ", "{% unless true %} NO {% else %} YES {% endunless %}")
    assert_template_result(" YES ", "{% unless false %} YES {% else %} NO {% endunless %}")
    assert_template_result(" YES ", "{% unless \"foo\" %} NO {% else %} YES {% endunless %}")
  end

  test :test_unless_in_loop do
    assert_template_result(
      "23",
      "{% for i in choices %}{% unless i %}{{ forloop.index }}{% endunless %}{% endfor %}",
      %{"choices" => [1, nil, false]}
    )
  end

  test :test_unless_else_in_loop do
    assert_template_result(
      " TRUE  2  3 ",
      "{% for i in choices %}{% unless i %} {{ forloop.index }} {% else %} TRUE {% endunless %}{% endfor %}",
      %{"choices" => [1, nil, false]}
    )
  end

  defp assert_template_result(expected, markup) do
    assert_result(expected, markup, %{})
  end

  defp assert_template_result(expected, markup, assigns) do
    assert_result(expected, markup, assigns)
  end

  defp assert_result(expected, markup, assigns) do
    t = Liquid.parse_template(:liquid, markup)
    {:ok, rendered, _} = Liquid.render_template(:liquid, t, assigns)
    assert rendered == expected
  end
end
