# Google Cloud Document AI Parser

[![Gem Version](https://badge.fury.io/rb/google-cloud-document_ai-parser.svg)](https://badge.fury.io/rb/google-cloud-document_ai-parser)
[![Build Status](https://github.com/czekaj/google-cloud-document_ai-parser/actions/workflows/ruby.yml/badge.svg)](https://github.com/czekaj/google-cloud-document_ai-parser/actions/workflows/ruby.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/YOUR_CODECLIMATE_BADGE_ID/maintainability)](https://codeclimate.com/github/czekaj/google-cloud-document_ai-parser/maintainability)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Parses the JSON response from Google Cloud Document AI processors into easy-to-use Ruby objects.

Navigating the raw JSON structure returned by Document AI can be cumbersome. This gem simplifies interaction by providing structured objects (`Document`, `Entity`, `LineItem`) with helper methods for accessing common fields and normalized values.

Initially built for the **Expense Parser**, the gem is designed to be pluggable, allowing easy extension for other Document AI processor types in the future.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'google-cloud-document_ai-parser'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install google-cloud-document_ai-parser
```

## Usage

1.  **Get your JSON response** from the Google Cloud Document AI API for a supported processor type.
2.  **Parse the response:**

```ruby
require 'google/cloud/document_ai/parser'
require 'json' # Or load your Hash however you prefer

# Example JSON response (string or file contents)
# Replace with your actual Document AI response
json_string = File.read('path/to/your_document_ai_response.json')
# Or if you already have a Hash:
# data_hash = JSON.parse(json_string)

begin
  # Specify the processor type used to generate the response
  document = Google::Cloud::DocumentAI::Parser.parse(json_string, processor_type: :expense_parser)
  # Or use the hash:
  # document = Google::Cloud::DocumentAI::Parser.parse(data_hash, processor_type: :expense_parser)

  # --- Access Top-Level Document Data ---
  puts "Supplier: #{document.supplier_name}"       # => "Trader Joe's"
  puts "Total Amount: #{document.total_amount}"   # => #<BigDecimal:...,'0.16244E3',9(18)> (i.e., 162.44)
  puts "Tax Amount: #{document.total_tax_amount}" # => #<BigDecimal:...,'0.117E1',9(18)> (i.e., 1.17)
  puts "Receipt Date: #{document.receipt_date}"   # => #<Date: 2024-11-27 ((2460641j,0s,0n),+0s,2299161j)>
  puts "Purchase Time: #{document.purchase_time}" # => 2024-11-27 10:05:00 +0000 (Time object, date defaults to receipt_date)
  puts "Currency: #{document.currency}"           # => "USD"
  puts "Payment Type: #{document.payment_type}"   # => "VISA"
  puts "Card Last 4: #{document.credit_card_last_four_digits}" # => "7268"

  # --- Access Line Items ---
  puts "\nLine Items:"
  document.line_items.each_with_index do |item, i|
    puts "  #{i+1}. Description: #{item.description}" # => "HOL POTATO WEDGES HERBS"
    puts "     Amount: #{item.amount}"               # => #<BigDecimal:...,'0.379E1',9(18)> (i.e., 3.79)
    puts "     Quantity: #{item.quantity}"           # => nil (or parsed Integer/Float if present)
    puts "     Unit Price: #{item.unit_price}"       # => nil (or BigDecimal if present)
  end

  # --- Access All Entities (including those used by helpers) ---
  puts "\nAll Entities:"
  document.entities.each do |entity|
    puts "  Type: #{entity.type}, Text: '#{entity.mention_text}', Confidence: #{entity.confidence.round(2)}"
    # Example accessing specific normalized value:
    # puts "    Normalized Amount: #{entity.amount}" if entity.type == :total_amount
  end

rescue Google::Cloud::DocumentAI::Parser::Error => e
  puts "Error parsing Document AI response: #{e.message}"
  # Handle specific errors like JsonParseError or UnknownProcessorError if needed
end
```

## Features

*   Parses JSON strings or pre-parsed Ruby Hashes.
*   Provides easy access to common document fields via helper methods (`supplier_name`, `total_amount`, `receipt_date`, etc.).
*   Provides access to the full list of `entities` and parsed `line_items`.
*   Includes helpers within `Entity` objects to access **normalized values** as appropriate Ruby types (`BigDecimal`, `Date`, `Time`).
*   Pluggable architecture to easily add support for different Document AI processor types.
*   Retains access to the `raw_data` for debugging or accessing non-standard fields.

## Supported Processors

Currently supports:

*   `:expense_parser` (Google Cloud Document AI Expense Parser)

Adding support for other processors (like Invoice Parser, Form Parser) is planned.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/czekaj/google-cloud-document_ai-parser](https://github.com/czekaj/google-cloud-document_ai-parser). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/czekaj/google-cloud-document_ai-parser/blob/main/CODE_OF_CONDUCT.md).

1.  Fork it (<https://github.com/czekaj/google-cloud-document_ai-parser/fork>)
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create a new Pull Request

Please add tests for any new code or changes.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Google::Cloud::DocumentAI::Parser project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/czekaj/google-cloud-document_ai-parser/blob/main/CODE_OF_CONDUCT.md).
