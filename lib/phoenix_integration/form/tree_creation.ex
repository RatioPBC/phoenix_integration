defmodule PhoenixIntegration.Form.TreeCreation do
  @moduledoc """
  The code in this module converts a Floki representation of an HTML
  form into a tree structure whose leaves are Tags: that is, descriptions
  of a form tag that can provide values to POST-style parameters.
  """
  alias PhoenixIntegration.Form.Tag

  ### Main interface
  
  def build_tree(form) do
    form
    |> form_to_floki_tags
    |> build_tree_from_floki_tags
  end

  #### Helpers, some exposed to tests

  defp form_to_floki_tags(form) do
    ["input", "textarea", "select"]
    |> Enum.flat_map(fn tag_name -> floki_tags(form, tag_name) end)
  end

  def build_tree_from_floki_tags(tags) do
    reducer = fn floki_tag, {tree_so_far, warnings} ->
      case Tag.new(floki_tag) do
        {:ok, tag} -> 
          {:ok, new_tree} = add_tag(tree_so_far, tag)
          {new_tree, warnings}
        {:warning, message_atom, data} ->
          {tree_so_far, warnings ++ [{message_atom, data}]}
      end
    end
    
    {tree, warnings} = Enum.reduce(tags, {%{}, []}, reducer)
    {:ok, tree, warnings}
  end
  

  def floki_tags(form, "input") do
    form
    |> Floki.find("input")
    |> Enum.map(&force_explicit_type/1)
    |> filter_types(["text", "checkbox", "hidden", "radio"])
  end

  def floki_tags(form, "textarea"), do: Floki.find(form, "textarea")
  def floki_tags(form, "select"), do: Floki.find(form, "select")

  # An omitted type counts as `text`
  defp force_explicit_type(floki_tag) do
    adjuster = fn {name, attributes, children} -> 
      {name, [{"type", "text"} | attributes], children}
    end

    case Floki.attribute(floki_tag, "type") do
      [] -> Floki.traverse_and_update(floki_tag, adjuster)
      [_] -> floki_tag
    end
  end

  def filter_types(floki_tags, allowed) do
    filter_one = fn floki_tag ->
      [type] = Floki.attribute(floki_tag, "type")
      type in allowed
    end
    
    Enum.filter(floki_tags, filter_one)
  end 
  
  def add_tag!(tree, %Tag{} = tag) do
    {:ok, new_tree} = add_tag(tree, tag)
    new_tree
  end
  
  def add_tag(tree, %Tag{} = tag) do
    try do
      {:ok, add_tag(tree, tag.path, tag)}
    catch
      error_code ->
        {:error, error_code}
    end
  end

  defp add_tag(tree, [last], %Tag{} = tag) do
    case Map.get(tree, last) do
      nil ->
        Map.put_new(tree, last, tag)
      %Tag{} ->
        Map.update!(tree, last, &(combine_values &1, tag))
      _ ->
        throw :lost_value
    end
  end

  defp add_tag(tree, [next | rest], %Tag{} = tag) do
    case Map.get(tree, next) do
      %Tag{} -> # we've reached a leaf but new Tag has path left
        throw :lost_value
      nil ->
        Map.put(tree, next, add_tag(%{}, rest, tag))
      _ -> 
        Map.update!(tree, next, &(add_tag &1, rest, tag))
    end
  end

  defp combine_values(earlier_tag, later_tag) do
    case {earlier_tag.type, later_tag.type, earlier_tag.has_list_value} do
      {"hidden", "checkbox", _} ->
        implement_hidden_hack(earlier_tag, later_tag)
      {"radio", "radio", false} ->
        implement_radio(earlier_tag, later_tag)
      {_, _, false} ->
        later_tag
      {_, _, true} ->
        %{earlier_tag | values: earlier_tag.values ++ later_tag.values}
    end
  end

  defp implement_hidden_hack(hidden_tag, checkbox_tag) do
    case checkbox_tag.values == [] do
      true -> hidden_tag
      false -> checkbox_tag
    end
  end

  defp implement_radio(earlier_tag, current_tag) do
    case current_tag.values == [] do
      true -> earlier_tag
      false -> current_tag
    end
  end
end  
