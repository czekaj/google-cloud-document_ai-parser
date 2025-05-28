# frozen_string_literal: true

module Google
  module Cloud
    module DocumentAI
      module Parser
        module Processors
          # Abstract base class for Document AI processors.
          class BaseProcessor
            attr_reader :raw_data

            # @param raw_data [Hash] The parsed JSON data from Document AI.
            def initialize(raw_data)
              @raw_data = raw_data
            end

            # Parses the raw data into a structured Document object.
            # Must be implemented by subclasses.
            # @return [Google::Cloud::DocumentAI::Parser::Document]
            def parse
              raise NotImplementedError, "#{self.class.name}#parse must be implemented"
            end
          end
        end
      end
    end
  end
end
