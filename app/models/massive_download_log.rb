class MassiveDownloadLog < ApplicationRecord

  def self.insert_massive_log(massive_data, status_state_code, message)
    data = {
      solicitud_id: massive_data[:id],
      worker: 'Validar',
      error_code: status_state_code,
      message: message,
      emmiter_id: massive_data[:emmiter_id]
    }
    massive_log = MassiveDownloadLog.new(data)

    return nil unless massive_log.save!
    return massive_log
  end

end