# frozen_string_literal: true

require "google-cloud-document_ai-parser" # Or the actual path if not installed yet
require "json"
require "bigdecimal"
require "date"
require "time"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Helper to load sample data
  def load_sample_json(filename)
    path = File.join(File.dirname(__FILE__), "sample_data", filename)
    raise "Sample data file not found: #{path}. Make sure it's in spec/sample_data/" unless File.exist?(path)

    File.read(path)
  end

  def parse_sample_json(filename)
    JSON.parse(load_sample_json(filename))
  end
end
