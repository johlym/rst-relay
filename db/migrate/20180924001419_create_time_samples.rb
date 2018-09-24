class CreateTimeSamples < ActiveRecord::Migration[5.2]
  def change
    create_table :time_samples do |t|
      t.string :location
      t.integer :value

      t.timestamps
    end
  end
end
