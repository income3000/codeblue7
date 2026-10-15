class CreateOfficialRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :official_records do |t|
      t.references :user, null: false, foreign_key: true
      t.string :category, null: false
      t.string :name, null: false
      t.string :district
      t.string :badge_number
      t.string :precinct
      t.string :state, null: false
      t.string :city, null: false
      t.text :incident_names
      t.string :case_number
      t.text :history
      t.text :decisions
      t.string :source_url
      t.timestamps null: false
    end

    add_index :official_records, :category
    add_index :official_records, :state
    add_index :official_records, :city
    add_index :official_records, :district
    add_index :official_records, :badge_number
    add_index :official_records, :precinct
    add_index :official_records, :case_number

    create_table :official_record_reviews do |t|
      t.references :official_record, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :professionalism_rating, null: false
      t.integer :experience_rating, null: false
      t.text :comment
      t.timestamps null: false
    end

    add_index :official_record_reviews, [ :official_record_id, :user_id ], unique: true,
      name: :index_official_record_reviews_on_record_and_user
  end
end
