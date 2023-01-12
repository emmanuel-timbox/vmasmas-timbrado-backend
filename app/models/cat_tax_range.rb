class CatTaxRange < ApplicationRecord

  def self.rate_formatted
    tarifas_de_impuestos = CatTaxRange.all
    tarifas_de_impuestos_formatted = {}

    i = 1
    tarifas_de_impuestos.each do |t|

      tasa_text = ''
      tasa_val_min = ''
      tasa_val_max = t.maximum_value
      tarifas_de_impuestos_formatted[i] = {}

      if t.fixed_range == 'F'
        tasa_text = t.factor_type + ' ' + t.maximum_value
      elsif t.fixed_range == 'R'
        tasa_text = t.factor_type + ' x Rango'
        tasa_val_min = t.minimum_value
      end

      if t.retention == 1
        tarifas_de_impuestos_formatted[i]['id'] = t.id
        tarifas_de_impuestos_formatted[i]['name'] = t.tax + ' Retenido ' + tasa_text
        tarifas_de_impuestos_formatted[i]['val_min'] = tasa_val_min
        tarifas_de_impuestos_formatted[i]['val_max'] = tasa_val_max
      end

      if t.transfer == 1
        if t.retention == 1
          i += 1
          tarifas_de_impuestos_formatted[i] = {}
        end
        tarifas_de_impuestos_formatted[i]['id'] = t.id
        tarifas_de_impuestos_formatted[i]['name'] = t.tax + ' Trasladado ' + tasa_text
        tarifas_de_impuestos_formatted[i]['val_min'] = tasa_val_min
        tarifas_de_impuestos_formatted[i]['val_max'] = tasa_val_max
      end

      i += 1
    end
    tarifas_de_impuestos_formatted
  end

end