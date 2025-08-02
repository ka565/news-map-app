class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics do |t|
      t.string :title
      t.text :description
      t.float :latitude
      t.float :longitude
      t.string :url
      t.string :image_url
      t.datetime :published_at

      t.timestamps
    end
  end
end
