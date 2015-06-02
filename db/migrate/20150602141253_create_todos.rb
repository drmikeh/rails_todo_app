class CreateTodos < ActiveRecord::Migration
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.boolean :completed, null: false

      t.timestamps null: false
    end
  end
end
