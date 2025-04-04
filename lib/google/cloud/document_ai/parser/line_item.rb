# frozen_string_literal: true

require 'bigdecimal'

module Google
  module Cloud
    module DocumentAI
      module Parser
        # Represents a parsed line item from the Expense Parser.
        class LineItem
          attr_reader :description, :quantity, :unit, :unit_price, :amount, :product_code,
                      :raw_line_item_entity, :raw_properties

          # @param line_item_entity_hash [Hash] The raw 'line_item' type entity hash.
          def initialize(line_item_entity_hash)
            @raw_line_item_entity = line_item_entity_hash
            @raw_properties = line_item_entity_hash['properties'] || []
            parse_properties
          end

          private

          def parse_properties
            @raw_properties.each do |prop_hash|
              entity = Entity.new(prop_hash) # Use Entity helpers for normalization
              case entity.type
              when :'line_item/description'
                @description = entity.text # Use normalized text or mentionText
              when :'line_item/quantity'
                # Attempt to parse quantity as Integer or Float
                @quantity = begin
                              Integer(entity.text)
                            rescue ArgumentError
                              begin
                                Float(entity.text)
                              rescue ArgumentError
                                entity.text # Fallback to raw text
                              end
                            end
              when :'line_item/unit'
                @unit = entity.text
              when :'line_item/unit_price'
                @unit_price = entity.amount
              when :'line_item/amount'
                @amount = entity.amount
              when :'line_item/product_code'
                @product_code = entity.text
                # Add other line_item/* types here as needed
              end
            end
            # Ensure amount is set even if only unit_price and quantity are present
            @amount ||= (@unit_price * BigDecimal(@quantity.to_s)) if @unit_price && @quantity.is_a?(Numeric)
          rescue StandardError => e
            # Basic error handling during property parsing
            warn "Error parsing line item properties: #{e.message}"
            @description ||= @raw_line_item_entity['mentionText'] # Fallback description
          end
        end
      end
    end
  end
end