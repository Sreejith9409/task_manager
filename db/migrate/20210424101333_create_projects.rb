class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.date :created_date
      t.integer :created_by
      t.timestamps
    end
  end
end
