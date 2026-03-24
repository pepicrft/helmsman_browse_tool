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
  - `"screenshot"` - Capture a screenshot (optional `format`, `quality`)
  - `"print_to_pdf"` - Print the current page to PDF
  - `"click"` - Click an element (requires `selector`)
  - `"fill"` - Fill a form field (requires `selector`, `value`)
  - `"wait_for"` - Wait for an element to appear (requires `selector`)
  - `"evaluate"` - Execute JavaScript (requires `expression`)
  """

  use Helmsman.Tool

  @impl true
  def name(_opts), do: "browse"

  @impl true
  def description(_opts) do
    """
    Browse the web. Supports navigating to URLs, reading page content,
    getting the current URL, capturing screenshots, printing to PDF,
    clicking elements, filling form fields, waiting for elements, and
    executing JavaScript.
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
          enum: [
            "navigate",
            "content",
            "current_url",
            "screenshot",
            "print_to_pdf",
            "click",
            "fill",
            "wait_for",
            "evaluate"
          ],
          description: "The browsing action to perform"
        },
        url: %{
          type: "string",
          description: "URL to navigate to (required for 'navigate' action)"
        },
        selector: %{
          type: "string",
          description: "CSS selector for the target element (required for 'click' and 'fill' actions)"
        },
        value: %{
          type: "string",
          description: "Value to fill into the form field (required for 'fill' action)"
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

  defp execute_action("navigate", %{"url" => url}, browser) do
    case Browse.navigate(browser, url, []) do
      :ok -> {{:ok, "Navigated to #{url}"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("navigate", _args, _browser) do
    {{:error, "Missing required parameter: url"}, :ok}
  end

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

  defp execute_action("click", %{"selector" => selector}, browser) do
    case Browse.click(browser, selector, []) do
      :ok -> {{:ok, "Clicked #{selector}"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("click", _args, _browser) do
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

  defp execute_action("wait_for", %{"selector" => selector}, browser) do
    case Browse.wait_for(browser, selector, []) do
      :ok -> {{:ok, "Element #{selector} is visible"}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("wait_for", _args, _browser) do
    {{:error, "Missing required parameter: selector"}, :ok}
  end

  defp execute_action("evaluate", %{"expression" => expression}, browser) do
    case Browse.evaluate(browser, expression, []) do
      {:ok, result} -> {{:ok, inspect(result)}, :ok}
      {:error, reason} -> {{:error, reason}, :ok}
    end
  end

  defp execute_action("evaluate", _args, _browser) do
    {{:error, "Missing required parameter: expression"}, :ok}
  end

  defp execute_action(action, _args, _browser) do
    {{:error,
      "Unknown action: #{action}. Expected one of: navigate, content, current_url, screenshot, print_to_pdf, click, fill, wait_for, evaluate"},
     :ok}
  end

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value), do: Keyword.put(opts, key, value)
end
