class AddOfficialRecordToIncidents < ActiveRecord::Migration[8.1]
  def change
    add_reference :incidents, :official_record, foreign_key: true, index: true
  end
end
