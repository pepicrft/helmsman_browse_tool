defmodule HelmsmanBrowseToolTest do
  use ExUnit.Case, async: false
  use Mimic

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
    end
  end

  describe "call/2" do
    setup do
      context = %{agent: self(), cwd: "/tmp", opts: [pool: :test_pool]}
      {:ok, context: context}
    end

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
