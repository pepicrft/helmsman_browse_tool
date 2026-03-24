# HelmsmanBrowseTool

A [Helmsman](https://github.com/pepicrft/helmsman) tool that gives AI agents the ability to browse the web using [Browse](https://github.com/pepicrft/browse).

## Installation

Add `helmsman_browse_tool` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:helmsman_browse_tool, "~> 0.1.0"}
  ]
end
```

## Usage

Add the browse tool to your Helmsman agent:

```elixir
defmodule MyAgent do
  use Helmsman

  @impl true
  def tools do
    [
      {HelmsmanBrowseTool, pool: MyApp.BrowserPool}
    ]
  end
end
```

The tool exposes a `browse` tool to the LLM with the following actions:

- **navigate** - Navigate to a URL
- **content** - Get the page content as text
- **screenshot** - Capture a screenshot of the current page
- **click** - Click an element on the page
- **fill** - Fill a form field
- **evaluate** - Execute JavaScript on the page

## Configuration

The tool requires a Browse pool to be configured. See the [Browse documentation](https://github.com/pepicrft/browse) for pool setup.
