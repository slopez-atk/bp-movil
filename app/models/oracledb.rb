class Oracledb < ApplicationRecord
  establish_connection "#{Rails.env}_sec".to_sym

  def self.getCreditosInmobiliarios
    results = connection.exec_query("Select * from inmobiliario")
    if results.present?
      return results
    else
      return nil
    end
  end

  def self.getCreditosConsumo
    results = connection.exec_query("Select * from consumo")
    if results.present?
      return results
    else
      return nil
    end
  end

  def self.getCreditosMicrocreditos
    results = connection.exec_query("Select * from microcredito")
    if results.present?
      return results
    else
      return nil
    end
  end

  def self.getCreditosProductivos
    results = connection.exec_query("Select * from productivo")
    if results.present?
      return results
    else
      return nil
    end
  end


end
