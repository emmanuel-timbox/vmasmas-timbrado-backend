class XmlFile < ApplicationRecord
  belongs_to :emitter, inverse_of: :xml_file_as_emitter, class_name: 'Emitter', optional: true, autosave: true

  def self.insert_xml(xml, emitter_id, note)
    cfdi = Nokogiri::XML(xml)
    xml_data_file = {
      emitter_id: Emitter.find_by(slug: emitter_id).id,
      uuid: cfdi.xpath("//tfd:TimbreFiscalDigital/@UUID", "xmlns:tfd" => "http://www.sat.gob.mx/TimbreFiscalDigital").text,
      emitte_date: cfdi.xpath("cfdi:Comprobante/@Fecha").text,
      stamp_date: cfdi.xpath("//tfd:TimbreFiscalDigital/@FechaTimbrado", "xmlns:tfd" => "http://www.sat.gob.mx/TimbreFiscalDigital").text,
      emitter_rfc: cfdi.xpath("cfdi:Comprobante/cfdi:Emisor/@Rfc").text,
      receiver_rfc: cfdi.xpath("cfdi:Comprobante/cfdi:Receptor/@Rfc").text,
      receiver_name: cfdi.xpath("cfdi:Comprobante/cfdi:Receptor/@Nombre").text,
      voucher_type: cfdi.xpath("cfdi:Comprobante/@TipoDeComprobante").text,
      total: cfdi.xpath("cfdi:Comprobante/@Total").text,
      xml: xml,
      is_stamped: true,
      is_prefacture: false,
      note: note,
      slug: EncryptData.encrypt('xml-file')
    }
    return XmlFile.create(xml_data_file)
  end

  def self.select_xmls(slug_user)
    return XmlFile.where(is_stamped: 1).where("emitters.user_id = #{User.find_by(slug: slug_user).id}")
                  .select("xml_files.uuid, xml_files.emitte_date, xml_files.stamp_date,
                          xml_files.emitter_rfc, xml_files.note, xml_files.receiver_rfc, xml_files.receiver_name,
                          xml_files.voucher_type, xml_files.total, xml_files.slug as slug_xml_file, xml_files.xml,
                          emitters.slug as slug_emitter, emitters.company_name, emitters.address")
                  .joins(:emitter)
  end

end