# frozen_string_literal: true

require 'date'
require 'bigdecimal'

module Google
  module Cloud
    module DocumentAI
      module Parser
        # Represents the parsed Document AI document, providing easy access to entities and line items.
        class Document
          attr_reader :entities, :line_items, :raw_data

          # @param entities [Array<Entity>] List of general parsed entities.
          # @param line_items [Array<LineItem>] List of parsed line items.
          # @param raw_data [Hash] The original input hash.
          def initialize(entities:, line_items:, raw_data:)
            @entities = entities
            @line_items = line_items
            @raw_data = raw_data
          end

          # Finds the first entity matching the given type.
          # @param type [Symbol] The entity type symbol (e.g., :supplier_name).
          # @return [Entity, nil] The found entity or nil.
          def find_entity(type)
            @entities.find { |e| e.type == type }
          end

          # Finds all entities matching the given type.
          # @param type [Symbol] The entity type symbol.
          # @return [Array<Entity>] An array of matching entities.
          def find_entities(type)
            @entities.select { |e| e.type == type }
          end

          # Helper methods for common expense fields
          # These return the normalized value directly for convenience

          def supplier_name
            find_entity(:supplier_name)&.text
          end

          def supplier_address
            find_entity(:supplier_address)&.text # Raw normalized text for now
            # TODO: Could parse address components from normalized('addressValue') later
          end

          def supplier_phone
            find_entity(:supplier_phone)&.text
          end

          def receipt_date
            find_entity(:receipt_date)&.date
          end

          def purchase_time
            receipt_entity = find_entity(:receipt_date)
            base_date = receipt_entity&.date || Date.today # Use receipt date or default
            find_entity(:purchase_time)&.time(base_date)
          end

          def total_amount
            find_entity(:total_amount)&.amount
          end

          def total_tax_amount
            find_entity(:total_tax_amount)&.amount
          end

          def currency
            # Find currency entity or try to infer from total_amount
            currency_entity = find_entity(:currency)
            return currency_entity.normalized('text') || currency_entity.mention_text if currency_entity

            total_entity = find_entity(:total_amount)
            total_entity&.normalized('moneyValue')&.[]('currencyCode')
          end

          def payment_type
            find_entity(:payment_type)&.text
          end

          def credit_card_last_four_digits
            find_entity(:credit_card_last_four_digits)&.text
          end

          def payment_authorization_id
            find_entity(:payment_authorization_id)&.text
          end

          # Add more helper methods as needed...
        end
      end
    end
  end
end