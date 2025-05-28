# frozen_string_literal: true

require 'json'
require_relative 'parser/version'
require_relative 'parser/entity'
require_relative 'parser/line_item'
require_relative 'parser/document'
require_relative 'parser/processors/base_processor'
require_relative 'parser/processors/expense_parser'

module Google
  module Cloud
    module DocumentAI
      # Main module for the Document AI Parser Gem.
      module Parser
        class Error < StandardError; end
        class JsonParseError < Error; end
        class UnknownProcessorError < Error; end

        # Mapping of processor type symbols to their classes.
        PROCESSORS = {
          expense_parser: Processors::ExpenseParser
          # Add other processor mappings here later, e.g.,
          # invoice_parser: Processors::InvoiceParser
        }.freeze

        # Parses a Document AI JSON response or Hash.
        #
        # @param input [String, Hash] The JSON string or pre-parsed Hash from Document AI.
        # @param processor_type [Symbol] The type of processor used (e.g., :expense_parser).
        # @return [Google::Cloud::DocumentAI::Parser::Document] The parsed document object.
        # @raise [JsonParseError] If the input string is invalid JSON.
        # @raise [UnknownProcessorError] If the processor_type is not supported.
        def self.parse(input, processor_type: :expense_parser)
          raw_data = parse_input(input)
          processor_class = PROCESSORS[processor_type]

          raise UnknownProcessorError, "Unknown processor type: #{processor_type}" unless processor_class

          processor = processor_class.new(raw_data)
          processor.parse
        end

        def self.parse_input(input)
          case input
          when String
            begin
              JSON.parse(input)
            rescue JSON::ParserError => e
              raise JsonParseError, "Failed to parse JSON input: #{e.message}"
            end
          when Hash
            input # Assume it's already parsed
          else
            raise ArgumentError, "Input must be a JSON String or a Hash, was #{input.class}"
          end
        end
      end
    end
  end
end
