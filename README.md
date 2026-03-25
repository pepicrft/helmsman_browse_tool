# 🌐 HelmsmanBrowseTool

A [Helmsman](https://github.com/pepicrft/helmsman) tool that gives AI agents the ability to browse the web using [Browse](https://github.com/pepicrft/browse). 🤖🧭

## 📦 Installation

Add `helmsman_browse_tool` to your list of dependencies in `mix.exs`, along with a browser backend:

```elixir
def deps do
  [
    {:helmsman_browse_tool, "~> 0.2.0"},

    # Pick a browser backend:
    {:browse_chrome, "~> 0.2"},  # Headless Chrome via CDP
    # or
    {:browse_servo, "~> 0.1"},   # Servo-powered browser
  ]
end
```

## 🚀 Usage

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

- 🧭 **navigate** — Navigate to a URL
- 📄 **content** — Get the page content as HTML
- 🔗 **current_url** — Get the current page URL
- 🏷️ **title** — Get the current page title
- 📸 **screenshot** — Capture a screenshot of the current page
- 📑 **print_to_pdf** — Print the current page to PDF
- 👆 **click** — Click an element on the page
- 🖱️ **hover** — Hover over an element
- ✏️ **fill** — Fill a form field
- 📋 **select_option** — Select an option in a dropdown
- ⏳ **wait_for** — Wait for an element to appear
- 📝 **get_text** — Get the text content of an element
- 🔍 **get_attribute** — Get an attribute of an element
- ⚡ **evaluate** — Execute JavaScript on the page
- ⬅️ **go_back** — Navigate back in browser history
- ➡️ **go_forward** — Navigate forward in browser history
- 🔄 **reload** — Reload the current page
- 🍪 **get_cookies** — Get all cookies
- 🍪 **set_cookie** — Set a cookie
- 🧹 **clear_cookies** — Clear all cookies

## ⚙️ Configuration

The tool requires a [Browse](https://github.com/pepicrft/browse) pool backed by a browser engine. You can choose between:

- **[BrowseChrome](https://github.com/pepicrft/browse_chrome)** — Headless Chrome via the Chrome DevTools Protocol
- **[BrowseServo](https://github.com/pepicrft/browse_servo)** — Servo-powered browser via Rustler NIFs

### Example with BrowseChrome

```elixir
# config/config.exs
config :browse_chrome,
  default_pool: MyApp.BrowserPool,
  pools: [
    {MyApp.BrowserPool, pool_size: 4}
  ]
```

```elixir
# application.ex
def start(_type, _args) do
  children = BrowseChrome.children() ++ [
    # ... your other children
  ]

  Supervisor.start_link(children, strategy: :one_for_one)
end
```

### Example with BrowseServo

```elixir
# config/config.exs
config :browse_servo,
  default_pool: MyApp.BrowserPool,
  pools: [
    {MyApp.BrowserPool, pool_size: 4}
  ]
```

```elixir
# application.ex
def start(_type, _args) do
  children = BrowseServo.children() ++ [
    # ... your other children
  ]

  Supervisor.start_link(children, strategy: :one_for_one)
end
```

## 📝 License

MIT
