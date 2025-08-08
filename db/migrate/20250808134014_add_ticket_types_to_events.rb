class AddTicketTypesToEvents < ActiveRecord::Migration[8.0]
  def change
    # Add JSON column to store ticket type configurations
    add_column :events, :ticket_types_config, :jsonb, default: []
    
    # Add index for better querying
    add_index :events, :ticket_types_config, using: :gin
    
    # Remove old single ticket fields (we'll keep them for now for backward compatibility)
    # add_column :events, :total_seats, :integer, default: 0
    
    # Populate existing events with default ticket type configuration
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE events 
          SET ticket_types_config = jsonb_build_array(
            jsonb_build_object(
              'name', ticket_category,
              'category', ticket_category,
              'price', ticket_price,
              'seats_available', seat_number,
              'description', 'Default ticket type'
            )
          )
          WHERE ticket_types_config = '[]'::jsonb OR ticket_types_config IS NULL
        SQL
      end
    end
  end
end
