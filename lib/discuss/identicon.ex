defmodule Discuss.Identicon do

  @moduledoc false

  alias Discuss.Identicon.Image

  @spec create_identicon(binary) :: binary | {:error, any}
  def create_identicon(input) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
    |> filter_odd_squares()
    |> build_pixel_map()
    |> draw_image()
    |> save_image(input)
  end

  @spec save_image(binary, binary) :: binary
  defp save_image(image, input) do
    identicon_path = Application.get_env(:discuss, :path_to_identicon)
    path = "#{identicon_path}/#{input}.png"

    unless File.exists?(identicon_path) do
      File.mkdir_p(identicon_path)
    end

    case File.write(path, image) do
      :ok ->
        path
      {:error, reason} ->
        IO.puts(reason, label: "Failed to store identicon because of")
        ""
    end
  end

  defp draw_image(%Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  defp build_pixel_map(%Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      {top_left, bottom_right}
    end

    %Image{image | pixel_map: pixel_map}
  end

  defp filter_odd_squares(%Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end
    %Image{image | grid: grid}
  end

  defp build_grid(%Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard) #step is NOT optional (despite the docs)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Image{image | grid: grid}
  end

  defp mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  defp pick_color(%Image{hex: [r,g,b | _tail]} = image) do
    %Image{image | color: {r, g, b}}
  end

  defp hash_input(input) do
    hex = :crypto.hash(:md5, input)
          |> :binary.bin_to_list()

    %Image{hex: hex}
  end
end
