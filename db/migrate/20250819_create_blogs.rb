class CreateBlogs < ActiveRecord::Migration[7.0]
  def change
    create_table :blogs, id: :uuid do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.string :author, null: false
      t.datetime :published_at
      t.timestamps
    end
  end
end
