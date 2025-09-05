class AddDonationFormTitleAndSubtitleToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :donation_title, :string
    add_column :projects, :donation_subtitle, :text
  end
end
