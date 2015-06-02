class AddUserRefToTodos < ActiveRecord::Migration
  def change
    add_reference :todos, :user, index: true, foreign_key: true, null: false
  end
end
