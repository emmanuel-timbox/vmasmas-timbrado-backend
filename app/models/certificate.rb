class Certificate < ApplicationRecord
  belongs_to :emitter_as_certficate, inverse_of: :certificate_as_emitter, class_name: 'Emitter'
end