class CreateCommunityFeatures < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :display_name, null: false
      t.text :bio
      t.string :role, null: false, default: "member"
      t.timestamps null: false

      t.index :email, unique: true
      t.index :reset_password_token, unique: true
      t.index :role
    end

    create_table :incidents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.string :location
      t.datetime :occurred_at
      t.timestamps null: false
    end

    create_table :comments do |t|
      t.references :incident, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps null: false
    end

    create_table :conversations do |t|
      t.references :user_one, null: false, foreign_key: { to_table: :users }
      t.references :user_two, null: false, foreign_key: { to_table: :users }
      t.timestamps null: false

      t.index [ :user_one_id, :user_two_id ], unique: true
    end

    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps null: false
    end
  end
end
