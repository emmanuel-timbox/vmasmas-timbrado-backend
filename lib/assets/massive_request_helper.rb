class MassiveRequestHelper

  def self.validate_request_times(init_date, end_date)
    is_validate = false
    data = { message: 'Favor de revisar que la Fecha inicial no sea mayor a la Fecha final de la solicitud', status: 500 }
    if Time.zone.parse(init_date) <= Time.zone.parse(end_date)
      is_validate = true
      data = { message: 'El rango de la Fecha es correcta', status: 200 }
    end
    return { is_validate: is_validate, data: data }
  end

  def self.validate_structure_rfc(rfc)
    is_validate = false
    data = { message: 'El formato del RFC que ingreso no es correcta', status: 500 }
    redex_rfc = /[A-Z&Ñ]{3,4}[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])[A-Z0-9]{2}[0-9A]/
    if redex_rfc.match(rfc).nil? && rfc.length.between?(12, 14)
      is_validate = true
      data = { message: "El que se ingreso es Valido", status: 200 }
    end
    return { is_validate: is_validate, data: data }
  end

end


