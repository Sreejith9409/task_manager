class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :name
      t.text :description
      t.string :status
      t.references :project, null: false, foreign_key: true
      t.integer :created_by
      t.integer :assigned_to
      t.date :created_date
      t.datetime :assigned_on
      t.datetime :completed_on
      t.integer :estimation_points
      t.datetime :estimated_completion_time
      t.string :licences, default: "000000000000000000000000000000"
      t.timestamps
    end
  end
end
