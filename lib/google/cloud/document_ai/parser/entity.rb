# frozen_string_literal: true

require 'bigdecimal'
require 'date'
require 'time'

module Google
  module Cloud
    module DocumentAI
      module Parser
        # Represents a single detected entity from the Document AI response.
        class Entity
          attr_reader :type, :mention_text, :confidence, :normalized_value, :bounding_poly, :raw_entity

          # @param entity_hash [Hash] The raw entity data from the Document AI JSON response.
          def initialize(entity_hash)
            @raw_entity = entity_hash
            @type = entity_hash['type']&.to_sym
            @mention_text = entity_hash['mentionText']
            @confidence = entity_hash['confidence']
            @normalized_value = entity_hash['normalizedValue'] # Keep raw for now
            @bounding_poly = entity_hash.dig('pageAnchor', 'pageRefs', 0, 'boundingPoly', 'normalizedVertices')
          end

          # Helper to get a specific normalized value type if it exists
          # @param key [String] e.g., "moneyValue", "dateValue", "text"
          # @return [Object, nil] The normalized value or nil.
          def normalized(key)
            @normalized_value&.[](key)
          end

          # Attempts to return a BigDecimal for money values.
          # @return [BigDecimal, nil]
          def amount
            val = normalized('moneyValue')
            return nil unless val

            units = val['units'] || '0'
            nanos = val['nanos'] || 0
            BigDecimal("#{units}.#{format('%09d', nanos)}")
          rescue ArgumentError
            nil # Handle cases where units/nanos might not form a valid number string
          end

          # Attempts to return a Date object for date values.
          # @return [Date, nil]
          def date
            val = normalized('dateValue')
            return nil unless val && val['year'] && val['month'] && val['day']

            Date.new(val['year'], val['month'], val['day'])
          rescue ArgumentError # Handle invalid dates
            nil
          end

          # Attempts to return a Time object for time values.
          # Note: Requires a base date, defaults to today if no date context.
          # @param base_date [Date] Optional date context.
          # @return [Time, nil]
          def time(base_date = Date.today)
            val = normalized('datetimeValue') || normalized('timeValue') # Check both possible keys
            return nil unless val

            hour = val['hours'] || 0
            min = val['minutes'] || 0
            sec = val['seconds'] || 0
            nanos = val['nanos'] || 0

            Time.new(base_date.year, base_date.month, base_date.day, hour, min, sec + (nanos / 1_000_000_000.0))
          rescue ArgumentError
            nil
          end

          # Returns the normalized text value.
          # @return [String, nil]
          def text
            # Handles direct text normalization or falls back to mentionText if no specific norm
            normalized('text') || mention_text
          end
        end
      end
    end
  end
end