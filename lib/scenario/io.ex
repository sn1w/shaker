defmodule Shaker.IO do
  def extract(glob) do
    Path.wildcard(glob)
  end

  def read_contents(file_paths) do
    file_paths 
    |> Enum.map(
      fn (path) ->
        {:ok, content} = File.read(path)
        content
      end
    )
  end
end