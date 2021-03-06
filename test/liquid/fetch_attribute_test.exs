Code.require_file("../../test_helper.exs", __ENV__.file)

defmodule FetchAttributeTest do
  use ExUnit.Case

  setup_all do
    start_supervised!({Liquid.Process, [name: :liquid]})
    :ok
  end

  defmodule User do
    defstruct name: "John", age: 27, about: [], data: %{}
  end

  defmodule Site do
    defstruct site: %{}
  end

  defmodule Values do
    defstruct input: 0, operand: 0
  end

  test 'empty test' do
    assert_template_result("", "{{}}")
  end

  test 'map fetch attribute' do
    assert_template_result("Tester", "{{user.name}}", %{"user" => %{"name" => "Tester"}})
  end

  test 'map fetch attribute array' do
    assert_template_result("first", "{{ site.users[0] }}", %{
      "site" => %{"users" => ["first", "second"]}
    })
  end

  test 'struct fetch attribute' do
    assert_template_result("Tester", "{{ data.name }}", %User{:data => %{"name" => "Tester"}})
    assert_template_result("John", "{{ name }}", %User{:data => %{"name" => "Tester"}})
  end

  test 'struct fetch attribute array' do
    assert_template_result("first", "{{ site.users[0] }}", %Site{
      site: %{"users" => ["first", "second"]}
    })
  end

  test 'struct fetch attribute filter' do
    assert_template_result("4", "{{ input | minus:operand }}", %Values{input: 5, operand: 1})
  end

  test 'assign map inside' do
    assigns = %{"arg" => %{"value" => 1}, "map" => %{"user" => %{"name" => "Tester"}}}
    assert_template_result("Tester1", "{{ map.user.name | append: arg.value }}", assigns)
  end

  test 'assign struct inside' do
    assigns = %{"arg" => %{"value" => 1}, "map" => %User{:data => %{"name" => "Tester"}}}
    assert_template_result("Tester1", "{{ map.data.name | append: arg.value }}", assigns)
  end

  defp assert_template_result(expected, markup, assigns \\ %{}) do
    assert_result(expected, markup, assigns)
  end

  defp assert_result(expected, markup, assigns) do
    t = Liquid.parse_template(:liquid, markup)
    {:ok, rendered, _} = Liquid.render_template(:liquid, t, assigns)
    assert rendered == expected
  end
end
