# frozen_string_literal: true

require "utils/github"

describe GitHub do
  describe "::search_code", :needs_network do
    it "queries GitHub code with the passed parameters" do
      results = subject.search_code(repo: "Homebrew/brew", path: "/",
                                    filename: "readme", language: "markdown")

      expect(results.count).to eq(1)
      expect(results.first["name"]).to eq("README.md")
      expect(results.first["path"]).to eq("README.md")
    end
  end

  describe "::query_string" do
    it "builds a query with the given hash parameters formatted as key:value" do
      query = subject.query_string(user: "Homebrew", repo: "brew")
      expect(query).to eq("q=user%3AHomebrew+repo%3Abrew&per_page=100")
    end

    it "adds a variable number of top-level string parameters to the query when provided" do
      query = subject.query_string("value1", "value2", user: "Homebrew")
      expect(query).to eq("q=value1+value2+user%3AHomebrew&per_page=100")
    end

    it "turns array values into multiple key:value parameters" do
      query = subject.query_string(user: ["Homebrew", "caskroom"])
      expect(query).to eq("q=user%3AHomebrew+user%3Acaskroom&per_page=100")
    end
  end

  describe "::search_issues", :needs_network do
    it "queries GitHub issues with the passed parameters" do
      results = subject.search_issues("brew search",
                                      repo:   "Homebrew/legacy-homebrew",
                                      author: "MikeMcQuaid",
                                      is:     "closed")
      expect(results).not_to be_empty
      expect(results.first["title"]).to eq("Shall we run `brew update` automatically?")
    end
  end

  describe "::approved_reviews", :needs_network do
    it "can get reviews for a pull request" do
      reviews = subject.approved_reviews("Homebrew", "homebrew-core", 1, commit: "deadbeef")
      expect(reviews).to eq([])
    end
  end

  describe "::get_artifact_url", :needs_network do
    it "fails to find a nonexistant workflow" do
      expect {
        subject.get_artifact_url("Homebrew", "homebrew-core", 1)
      }.to raise_error(/No matching workflow run found/)
    end

    it "fails to find artifacts that don't exist" do
      expect {
        subject.get_artifact_url("Homebrew", "homebrew-core", 51971, artifact_name: "false_bottles")
      }.to raise_error(/No artifact .+ was found/)
    end

    it "gets an artifact link" do
      url = subject.get_artifact_url("Homebrew", "homebrew-core", 51971, artifact_name: "bottles")
      expect(url).to eq("https://api.github.com/repos/Homebrew/homebrew-core/actions/artifacts/3557392/zip")
    end
  end
end
