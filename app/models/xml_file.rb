class XmlFile < ApplicationRecord

  def self.insert_xml(xml, user_slug)
    cfdi = Nokogiri::XML(xml)
    uuid = cfdi.xpath("//tfd:TimbreFiscalDigital/@UUID", "xmlns:tfd" =>
      "http://www.sat.gob.mx/TimbreFiscalDigital").text
    xml_data_file = {
      user_id: User.find_by(slug: user_slug).id,
      uuid: uuid,
      xml: xml,
      is_stamped: true,
      is_prefacture: false,
      slug: EncryptData.encrypt('xml-file')
    }
    return XmlFile.create(xml_data_file)
  end

end