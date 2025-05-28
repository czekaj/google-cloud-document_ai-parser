# frozen_string_literal: true

require_relative '../entity'
require_relative '../line_item'
require_relative '../document'
require_relative 'base_processor'

module Google
  module Cloud
    module DocumentAI
      module Parser
        module Processors
          # Processor implementation for Google's Expense Parser.
          class ExpenseParser < BaseProcessor
            def parse
              entities = []
              line_items = []

              raw_entities = @raw_data.dig('document', 'entities') || []

              raw_entities.each do |entity_hash|
                if entity_hash['type'] == 'line_item'
                  # It's a line item group
                  line_items << LineItem.new(entity_hash)
                else
                  # It's a regular entity
                  entities << Entity.new(entity_hash)
                  # NOTE: We could optionally exclude line_item/* properties if desired,
                  # but currently Entity doesn't parse sub-types, so they act like normal entities.
                  # If we wanted strict separation, we'd check for 'line_item/' prefix here.
                end
              end

              Document.new(entities: entities, line_items: line_items, raw_data: @raw_data)
            end
          end
        end
      end
    end
  end
end
