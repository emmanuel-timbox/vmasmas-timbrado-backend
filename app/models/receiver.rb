class Receiver < ApplicationRecord
  has_many :employee_receiver, inverse_of: :receiver_as_employee, foreign_key: :receiver_id, class_name: 'Employee'
  belongs_to :issuer, inverse_of: :receiver_emitter, class_name: 'Emitter', optional: true, autosave: true

  def self.get_data_receiver(slug)
    return Receiver.where(issuer_id: Emitter.find_by(slug: slug).id)
                   .select(:bussiness_name, :rfc, :cfdi_use, :receiving_tax_domicile, :status,
                           :slug, :recipient_tax_regimen, :tax_id_number, :recipient_tax_regimen, :tax_residence,
                           :receiving_tax_domicile, :have_payroll)
  end

  def self.insert_receiver(params)
    data = {
      issuer_id: Emitter.find_by(slug: params[:slugEmitter]).id,
      rfc: params[:rfc],
      bussiness_name: params[:bussinessName],
      cfdi_use: params[:cfdiUse],
      receiving_tax_domicile: params[:receivingTaxDomicile],
      recipient_tax_regimen: params[:recipientTaxRegimen],
      tax_id_number: params[:taxIdNumber],
      tax_residence: params[:tax_residence],
      status: 1,
      slug: EncryptData.encrypt('receiver')
    }
    return Receiver.create(data)
  end

  def self.update_status_receiver(slug)
    receiver = Receiver.find_by(slug: slug)
    status_init = receiver[:status]
    receiver.status = 0 if status_init == 1
    receiver.status = 1 if status_init == 0
    save = receiver.save!
    return { save: save, result: receiver }
  end

  def self.update_receiver(data_receiver)
    data = Receiver.find_by(slug: data_receiver[:id])
    data[:bussiness_name] = data_receiver[:bussinessName]
    data[:cfdi_use] = data_receiver[:cfdiUse]
    data[:receiving_tax_domicile] = data_receiver[:receivingTaxDomicile]
    data[:recipient_tax_regimen] = data_receiver[:recipientTaxRegimen]
    data[:tax_id_number] = data_receiver[:taxIdNumber]
    data[:tax_residence] = data_receiver[:tax_residence]
    save_data = data.save!
    return { save_data: save_data, result: data }
  end

  def self.insert_receiver_by_excel(row, issuer_id)
    receiver = {
      issuer_id: issuer_id,
      bussiness_name: row[1],
      rfc: row[2],
      cfdi_use: row[3],
      receiving_tax_domicile: row[4],
      recipient_tax_regimen: row[5],
      status: 1,
      slug: EncryptData.encrypt('receiver'),
      have_payroll: 1
    }
    return Receiver.create(receiver)
  end

  def self.update_receiver_by_excel(receiver)
    data = Receiver.find_by(slug: receiver[:slug_receiver])
    data[:bussiness_name] = receiver[:bussiness_name]
    data[:cfdi_use] = receiver[:cfdi_use]
    data[:receiving_tax_domicile] = receiver[:receiving_tax_domicile]
    data[:recipient_tax_regimen] = receiver[:recipient_tax_regimen]
    save_data = data.save!
    return { save_data: save_data, result: data }
  end

  def self.update_status_receiver_employee(params)
    begin
      data = nil

      ActiveRecord::Base.transaction do
        if params['havePayroll'] == 0
          data = update_status_receiver(params['slug'])
        else
          receiver = update_status_receiver(params['slug'])
          slug_employee = Employee.find_by(receiver_id: receiver[:result][:id]).slug
          employee = Employee.update_status_employee(slug_employee)

          raise ActiveRecord::Rollback unless receiver[:save]
          raise ActiveRecord::Rollback unless employee[:save]

          data = receiver[:result]
        end
      end

      return { save: true, result: data }
    rescue Exception => e
      return { save: false, result: nil }
    end
  end

end
  