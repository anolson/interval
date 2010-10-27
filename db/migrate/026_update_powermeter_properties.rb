class UpdatePowermeterProperties < ActiveRecord::Migration
  def self.up
    TrainingFile.all.each { |file|
      if(file.powermeter_properties.respond_to?("class"))
        file.powermeter_properties.class = "Joule::SRM::Properties" if(file.powermeter_properties.class.eql?("SrmProperties"))
        file.powermeter_properties.class = "Joule::IBike::Properties" if(file.powermeter_properties.class.eql?("IbikeProperties"))
        file.powermeter_properties.class = "Joule::Powertap::Properties" if(file.powermeter_properties.class.eql?("PowertapProperties"))
        file.save!
      end
    }
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
