defmodule HelmsmanBrowseToolTest do
  use ExUnit.Case, async: true
  use Mimic

  setup :set_mimic_private

  describe "name/1" do
    test "returns browse" do
      assert HelmsmanBrowseTool.name([]) == "browse"
    end
  end

  describe "description/1" do
    test "returns a non-empty description" do
      description = HelmsmanBrowseTool.description([])
      assert is_binary(description)
      assert String.length(description) > 0
    end
  end

  describe "parameters/1" do
    test "returns a valid JSON schema with action as required" do
      params = HelmsmanBrowseTool.parameters([])
      assert params.type == "object"
      assert "action" in params.required
      assert Map.has_key?(params.properties, :action)
      assert Map.has_key?(params.properties, :url)
      assert Map.has_key?(params.properties, :selector)
      assert Map.has_key?(params.properties, :value)
      assert Map.has_key?(params.properties, :expression)
      assert Map.has_key?(params.properties, :name)
      assert Map.has_key?(params.properties, :domain)
    end
  end

  describe "call/2" do
    setup do
      context = %{agent: self(), cwd: "/tmp", opts: [pool: :test_pool]}
      {:ok, context: context}
    end

    # Navigation

    test "navigate action calls Browse.navigate", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :navigate, fn ^browser, "https://example.com", [] ->
        :ok
      end)

      assert {:ok, "Navigated to https://example.com"} ==
               HelmsmanBrowseTool.call(%{"action" => "navigate", "url" => "https://example.com"}, context)
    end

    test "navigate action returns error when url is missing", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      assert {:error, "Missing required parameter: url"} ==
               HelmsmanBrowseTool.call(%{"action" => "navigate"}, context)
    end

    test "go_back action calls Browse.go_back", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :go_back, fn ^browser ->
        :ok
      end)

      assert {:ok, "Navigated back"} ==
               HelmsmanBrowseTool.call(%{"action" => "go_back"}, context)
    end

    test "go_forward action calls Browse.go_forward", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :go_forward, fn ^browser ->
        :ok
      end)

      assert {:ok, "Navigated forward"} ==
               HelmsmanBrowseTool.call(%{"action" => "go_forward"}, context)
    end

    test "reload action calls Browse.reload", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :reload, fn ^browser ->
        :ok
      end)

      assert {:ok, "Page reloaded"} ==
               HelmsmanBrowseTool.call(%{"action" => "reload"}, context)
    end

    # Page info

    test "content action calls Browse.content", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :content, fn ^browser ->
        {:ok, "<html><body>Hello</body></html>"}
      end)

      assert {:ok, "<html><body>Hello</body></html>"} ==
               HelmsmanBrowseTool.call(%{"action" => "content"}, context)
    end

    test "current_url action calls Browse.current_url", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :current_url, fn ^browser ->
        {:ok, "https://example.com/page"}
      end)

      assert {:ok, "https://example.com/page"} ==
               HelmsmanBrowseTool.call(%{"action" => "current_url"}, context)
    end

    test "title action calls Browse.title", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :title, fn ^browser ->
        {:ok, "Example Page"}
      end)

      assert {:ok, "Example Page"} ==
               HelmsmanBrowseTool.call(%{"action" => "title"}, context)
    end

    # Capture

    test "screenshot action calls Browse.capture_screenshot", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :capture_screenshot, fn ^browser, [] ->
        {:ok, "fake_png_data"}
      end)

      assert {:ok, %{type: :image, media_type: "image/png", data: Base.encode64("fake_png_data")}} ==
               HelmsmanBrowseTool.call(%{"action" => "screenshot"}, context)
    end

    test "print_to_pdf action calls Browse.print_to_pdf", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :print_to_pdf, fn ^browser ->
        {:ok, "fake_pdf_data"}
      end)

      assert {:ok, %{type: :document, media_type: "application/pdf", data: Base.encode64("fake_pdf_data")}} ==
               HelmsmanBrowseTool.call(%{"action" => "print_to_pdf"}, context)
    end

    # Element interaction

    test "click action calls Browse.click", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :click, fn ^browser, "#submit", [] ->
        :ok
      end)

      assert {:ok, "Clicked #submit"} ==
               HelmsmanBrowseTool.call(%{"action" => "click", "selector" => "#submit"}, context)
    end

    test "click action returns error when selector is missing", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      assert {:error, "Missing required parameter: selector"} ==
               HelmsmanBrowseTool.call(%{"action" => "click"}, context)
    end

    test "hover action calls Browse.hover", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :hover, fn ^browser, "#menu", [] ->
        :ok
      end)

      assert {:ok, "Hovered over #menu"} ==
               HelmsmanBrowseTool.call(%{"action" => "hover", "selector" => "#menu"}, context)
    end

    test "hover action returns error when selector is missing", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      assert {:error, "Missing required parameter: selector"} ==
               HelmsmanBrowseTool.call(%{"action" => "hover"}, context)
    end

    test "fill action calls Browse.fill", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :fill, fn ^browser, "#email", "test@example.com", [] ->
        :ok
      end)

      assert {:ok, "Filled #email with value"} ==
               HelmsmanBrowseTool.call(
                 %{"action" => "fill", "selector" => "#email", "value" => "test@example.com"},
                 context
               )
    end

    test "fill action returns error when params are missing", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      assert {:error, "Missing required parameters: selector and value"} ==
               HelmsmanBrowseTool.call(%{"action" => "fill"}, context)
    end

    test "select_option action calls Browse.select_option", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :select_option, fn ^browser, "#country", "us", [] ->
        :ok
      end)

      assert {:ok, "Selected us in #country"} ==
               HelmsmanBrowseTool.call(
                 %{"action" => "select_option", "selector" => "#country", "value" => "us"},
                 context
               )
    end

    test "select_option action returns error when params are missing", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      assert {:error, "Missing required parameters: selector and value"} ==
               HelmsmanBrowseTool.call(%{"action" => "select_option"}, context)
    end

    test "wait_for action calls Browse.wait_for", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :wait_for, fn ^browser, "#loading", [] ->
        :ok
      end)

      assert {:ok, "Element #loading is visible"} ==
               HelmsmanBrowseTool.call(%{"action" => "wait_for", "selector" => "#loading"}, context)
    end

    test "wait_for action returns error when selector is missing", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      assert {:error, "Missing required parameter: selector"} ==
               HelmsmanBrowseTool.call(%{"action" => "wait_for"}, context)
    end

    # Element queries

    test "get_text action calls Browse.get_text", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :get_text, fn ^browser, "h1", [] ->
        {:ok, "Hello World"}
      end)

      assert {:ok, "Hello World"} ==
               HelmsmanBrowseTool.call(%{"action" => "get_text", "selector" => "h1"}, context)
    end

    test "get_text action returns error when selector is missing", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      assert {:error, "Missing required parameter: selector"} ==
               HelmsmanBrowseTool.call(%{"action" => "get_text"}, context)
    end

    test "get_attribute action calls Browse.get_attribute", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :get_attribute, fn ^browser, "a", "href", [] ->
        {:ok, "https://example.com"}
      end)

      assert {:ok, "https://example.com"} ==
               HelmsmanBrowseTool.call(
                 %{"action" => "get_attribute", "selector" => "a", "name" => "href"},
                 context
               )
    end

    test "get_attribute action returns error when params are missing", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      assert {:error, "Missing required parameters: selector and name"} ==
               HelmsmanBrowseTool.call(%{"action" => "get_attribute"}, context)
    end

    # JavaScript

    test "evaluate action calls Browse.evaluate", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :evaluate, fn ^browser, "document.title", [] ->
        {:ok, "My Page"}
      end)

      assert {:ok, "\"My Page\""} ==
               HelmsmanBrowseTool.call(%{"action" => "evaluate", "expression" => "document.title"}, context)
    end

    test "evaluate action returns error when expression is missing", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      assert {:error, "Missing required parameter: expression"} ==
               HelmsmanBrowseTool.call(%{"action" => "evaluate"}, context)
    end

    # Cookies

    test "get_cookies action calls Browse.get_cookies", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :get_cookies, fn ^browser ->
        {:ok, [%{"name" => "session", "value" => "abc123"}]}
      end)

      assert {:ok, ~s([%{"name" => "session", "value" => "abc123"}])} ==
               HelmsmanBrowseTool.call(%{"action" => "get_cookies"}, context)
    end

    test "set_cookie action calls Browse.set_cookie", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :set_cookie, fn ^browser, %{"name" => "token", "value" => "xyz", "domain" => ".example.com"} ->
        :ok
      end)

      assert {:ok, "Cookie token set"} ==
               HelmsmanBrowseTool.call(
                 %{"action" => "set_cookie", "name" => "token", "value" => "xyz", "domain" => ".example.com"},
                 context
               )
    end

    test "set_cookie action returns error when params are missing", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      assert {:error, "Missing required parameters: name, value, and domain"} ==
               HelmsmanBrowseTool.call(%{"action" => "set_cookie"}, context)
    end

    test "clear_cookies action calls Browse.clear_cookies", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      expect(Browse, :clear_cookies, fn ^browser ->
        :ok
      end)

      assert {:ok, "Cookies cleared"} ==
               HelmsmanBrowseTool.call(%{"action" => "clear_cookies"}, context)
    end

    # Error cases

    test "unknown action returns error", %{context: context} do
      browser = %Browse{implementation: nil, state: nil}

      expect(Browse, :checkout, fn :test_pool, fun, [timeout: 30_000] ->
        {result, :ok} = fun.(browser)
        result
      end)

      assert {:error, "Unknown action: invalid" <> _} =
               HelmsmanBrowseTool.call(%{"action" => "invalid"}, context)
    end

    test "missing action returns error", %{context: context} do
      assert {:error, "Missing required parameter: action"} ==
               HelmsmanBrowseTool.call(%{}, context)
    end
  end
end
