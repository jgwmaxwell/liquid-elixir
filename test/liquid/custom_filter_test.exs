Code.require_file("../../test_helper.exs", __ENV__.file)

defmodule Liquid.CustomFilterTest do
  use ExUnit.Case

  defmodule MyFilter do
    def meaning_of_life(_), do: 42
  end

  defmodule MyFilterTwo do
    def meaning_of_life(_), do: 40
    def not_meaning_of_life(_), do: 2
  end

  defmodule FilterNameOverride do
    def filter_name_override_map, do: %{if: :if_filter}
    def if_filter(_), do: 43
  end

  setup_all do
    start_supervised!({Liquid.Process, [name: :liquid]})
    Liquid.add_filters(:liquid, MyFilter)
    Liquid.add_filters(:liquid, MyFilterTwo)
    Liquid.add_filters(:liquid, FilterNameOverride)
    :ok
  end

  test "custom filter uses the first passed filter" do
    assert_template_result("42", "{{ 'whatever' | meaning_of_life }}")
  end

  test :nonexistent_in_custom_chain do
    assert_template_result(
      "Liquid error: Non-existing filter used: minus_nonexistent",
      "{{ 'text' | capitalize | not_meaning_of_life | minus_nonexistent: 1 }}"
    )
  end

  test :custom_filter_in_chain do
    assert_template_result(
      "41",
      "{{ 'text' | upcase | nonexistent | meaning_of_life | minus: 1 }}"
    )
  end

  test "custom filter with name override" do
    assert_template_result("43", "{{ 'something' | if }}")
  end

  defp assert_template_result(expected, markup, assigns \\ %{}) do
    assert_result(expected, markup, assigns)
  end

  defp assert_result(expected, markup, assigns) do
    template = Liquid.parse_template(:liquid, markup)

    with {:ok, result, _} <- Liquid.render_template(:liquid, template, assigns) do
      assert result == expected
    else
      {:error, message, _} ->
        assert message == expected
    end
  end
end
