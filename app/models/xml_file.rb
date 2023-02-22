class XmlFile < ApplicationRecord

  def self.insert_xml(xml, user_slug)
    cfdi = Nokogiri::XML(xml)
    xml_data_file = {
      user_id: User.find_by(slug: user_slug).id,
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
      slug: EncryptData.encrypt('xml-file')
    }
    return XmlFile.create(xml_data_file)
  end

  def self.select_xmls(slug_user)
    return XmlFile.where(user_id: User.find_by(slug: slug_user).id, is_stamped: 1)
                  .select(:uuid, :emitte_date, :stamp_date, :emitter_rfc,
                          :receiver_rfc, :receiver_name, :voucher_type, :total, :slug, :xml)
  end

end