defmodule HelmsmanBrowseTool do
  @moduledoc """
  A Helmsman tool that gives AI agents the ability to browse the web.

  This tool wraps the `Browse` library to expose web navigation, content
  extraction, screenshots, clicking, form filling, and JavaScript evaluation
  as a single parameterized tool for Helmsman agents.

  ## Usage

      defmodule MyAgent do
        use Helmsman

        @impl true
        def tools do
          [
            {HelmsmanBrowseTool, pool: MyApp.BrowserPool}
          ]
        end
      end

  ## Actions

  The tool accepts an `action` parameter with one of:

  - `"navigate"` - Navigate to a URL (requires `url`)
  - `"content"` - Get the current page content as HTML
  - `"current_url"` - Get the current page URL
  - `"title"` - Get the current page title
  - `"screenshot"` - Capture a screenshot (optional `format`, `quality`)
  - `"print_to_pdf"` - Print the current page to PDF
  - `"click"` - Click an element (requires `selector`)
  - `"hover"` - Hover over an element (requires `selector`)
  - `"fill"` - Fill a form field (requires `selector`, `value`)
  - `"select_option"` - Select an option in a dropdown (requires `selector`, `value`)
  - `"wait_for"` - Wait for an element to appear (requires `selector`)
  - `"get_text"` - Get the text content of an element (requires `selector`)
  - `"get_attribute"` - Get an attribute of an element (requires `selector`, `name`)
  - `"evaluate"` - Execute JavaScript (requires `expression`)
  - `"go_back"` - Navigate back in browser history
  - `"go_forward"` - Navigate forward in browser history
  - `"reload"` - Reload the current page
  - `"get_cookies"` - Get all cookies for the current page
  - `"set_cookie"` - Set a cookie (requires `name`, `value`, `domain`)
  - `"clear_cookies"` - Clear all cookies
  """

  use Helmsman.Tool

  @actions [
    "navigate",
    "content",
    "current_url",
    "title",
    "screenshot",
    "print_to_pdf",
    "click",
    "hover",
    "fill",
    "select_option",
    "wait_for",
    "get_text",
    "get_attribute",
    "evaluate",
    "go_back",
    "go_forward",
    "reload",
    "get_cookies",
    "set_cookie",
    "clear_cookies"
  ]

  @impl true
  def name(_opts), do: "browse"

  @impl true
  def description(_opts) do
    """
    Browse the web. Supports navigating to URLs, reading page content,
    getting the current URL and title, capturing screenshots, printing to PDF,
    clicking and hovering over elements, filling form fields, selecting options,
    waiting for elements, reading text and attributes, executing JavaScript,
    browser history navigation, and cookie management.
    """
    |> String.trim()
  end

  @impl true
  def parameters(_opts) do
    %{
      type: "object",
      properties: %{
        action: %{
          type: "string",
          enum: @actions,
          description: "The browsing action to perform"
        },
        url: %{
          type: "string",
          description: "URL to navigate to (required for 'navigate' action)"
        },
        selector: %{
          type: "string",
          description:
            "CSS selector for the target element (required for 'click', 'hover', 'fill', 'select_option', 'wait_for', 'get_text', 'get_attribute' actions)"
        },
        value: %{
          type: "string",
          description: "Value to fill or select (required for 'fill', 'select_option', 'set_cookie' actions)"
        },
        name: %{
          type: "string",
          description: "Attribute or cookie name (required for 'get_attribute', 'set_cookie' actions)"
        },
        domain: %{
          type: "string",
          description: "Cookie domain (required for 'set_cookie' action)"
        },
        expression: %{
          type: "string",
          description: "JavaScript expression to evaluate (required for 'evaluate' action)"
        },
        format: %{
          type: "string",
          enum: ["png", "jpeg"],
          description: "Screenshot format (default: 'png')"
        },
        quality: %{
          type: "integer",
          description: "Screenshot quality for JPEG (1-100)"
        }
      },
      required: ["action"]
    }
  end

  @impl true
  def call(%{"action" => action} = args, context) do
    pool = context.opts[:pool] || Browse.default_pool!()
    timeout = context.opts[:timeout] || 30_000

    Browse.checkout(pool, fn browser -> execute_action(action, args, browser) end, timeout: timeout)
  end

  def call(_args, _context) do
    {:error, "Missing required parameter: action"}
  end

  # Navigation

  defp execute_action("navigate", %{"url" => url}, browser) do
    case Browse.navigate(browser, url, []) do
      :ok -> {{:ok, "Navigated to #{url}"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("navigate", _args, _browser) do
    {{:error, "Missing required parameter: url"}, :ok}
  end

  defp execute_action("go_back", _args, browser) do
    case Browse.go_back(browser) do
      :ok -> {{:ok, "Navigated back"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("go_forward", _args, browser) do
    case Browse.go_forward(browser) do
      :ok -> {{:ok, "Navigated forward"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("reload", _args, browser) do
    case Browse.reload(browser) do
      :ok -> {{:ok, "Page reloaded"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  # Page info

  defp execute_action("content", _args, browser) do
    case Browse.content(browser) do
      {:ok, content} -> {{:ok, content}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("current_url", _args, browser) do
    case Browse.current_url(browser) do
      {:ok, url} -> {{:ok, url}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("title", _args, browser) do
    case Browse.title(browser) do
      {:ok, title} -> {{:ok, title}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  # Capture

  defp execute_action("screenshot", args, browser) do
    opts =
      []
      |> maybe_put(:format, args["format"])
      |> maybe_put(:quality, args["quality"])

    case Browse.capture_screenshot(browser, opts) do
      {:ok, data} ->
        format = args["format"] || "png"
        media_type = if format == "jpeg", do: "image/jpeg", else: "image/png"

        result = %{
          type: :image,
          media_type: media_type,
          data: Base.encode64(data)
        }

        {{:ok, result}, :ok}

      {:error, reason} ->
        {{:error, reason}, :ok}
    end
  end

  defp execute_action("print_to_pdf", _args, browser) do
    case Browse.print_to_pdf(browser) do
      {:ok, data} ->
        result = %{
          type: :document,
          media_type: "application/pdf",
          data: Base.encode64(data)
        }

        {{:ok, result}, :ok}

      {:error, reason} ->
        {{:error, reason}, :ok}
    end
  end

  # Element interaction

  defp execute_action("click", %{"selector" => selector}, browser) do
    case Browse.click(browser, selector, []) do
      :ok -> {{:ok, "Clicked #{selector}"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("click", _args, _browser) do
    {{:error, "Missing required parameter: selector"}, :ok}
  end

  defp execute_action("hover", %{"selector" => selector}, browser) do
    case Browse.hover(browser, selector, []) do
      :ok -> {{:ok, "Hovered over #{selector}"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("hover", _args, _browser) do
    {{:error, "Missing required parameter: selector"}, :ok}
  end

  defp execute_action("fill", %{"selector" => selector, "value" => value}, browser) do
    case Browse.fill(browser, selector, value, []) do
      :ok -> {{:ok, "Filled #{selector} with value"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("fill", _args, _browser) do
    {{:error, "Missing required parameters: selector and value"}, :ok}
  end

  defp execute_action("select_option", %{"selector" => selector, "value" => value}, browser) do
    case Browse.select_option(browser, selector, value, []) do
      :ok -> {{:ok, "Selected #{value} in #{selector}"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("select_option", _args, _browser) do
    {{:error, "Missing required parameters: selector and value"}, :ok}
  end

  defp execute_action("wait_for", %{"selector" => selector}, browser) do
    case Browse.wait_for(browser, selector, []) do
      :ok -> {{:ok, "Element #{selector} is visible"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("wait_for", _args, _browser) do
    {{:error, "Missing required parameter: selector"}, :ok}
  end

  # Element queries

  defp execute_action("get_text", %{"selector" => selector}, browser) do
    case Browse.get_text(browser, selector, []) do
      {:ok, text} -> {{:ok, text}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("get_text", _args, _browser) do
    {{:error, "Missing required parameter: selector"}, :ok}
  end

  defp execute_action("get_attribute", %{"selector" => selector, "name" => name}, browser) do
    case Browse.get_attribute(browser, selector, name, []) do
      {:ok, value} -> {{:ok, value}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("get_attribute", _args, _browser) do
    {{:error, "Missing required parameters: selector and name"}, :ok}
  end

  # JavaScript

  defp execute_action("evaluate", %{"expression" => expression}, browser) do
    case Browse.evaluate(browser, expression, []) do
      {:ok, result} -> {{:ok, inspect(result)}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("evaluate", _args, _browser) do
    {{:error, "Missing required parameter: expression"}, :ok}
  end

  # Cookies

  defp execute_action("get_cookies", _args, browser) do
    case Browse.get_cookies(browser) do
      {:ok, cookies} -> {{:ok, inspect(cookies)}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("set_cookie", %{"name" => name, "value" => value, "domain" => domain}, browser) do
    cookie = %{"name" => name, "value" => value, "domain" => domain}

    case Browse.set_cookie(browser, cookie) do
      :ok -> {{:ok, "Cookie #{name} set"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("set_cookie", _args, _browser) do
    {{:error, "Missing required parameters: name, value, and domain"}, :ok}
  end

  defp execute_action("clear_cookies", _args, browser) do
    case Browse.clear_cookies(browser) do
      :ok -> {{:ok, "Cookies cleared"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  # Unknown

  defp execute_action(action, _args, _browser) do
    {{:error, "Unknown action: #{action}. Expected one of: #{Enum.join(@actions, ", ")}"}, :ok}
  end

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value), do: Keyword.put(opts, key, value)
end
