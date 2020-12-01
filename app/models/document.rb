class Document < ApplicationRecord
    has_one_attached :output
    has_many_attached :inputs
    has_many :sorted_inputs, -> { where(name: "inputs").order(position: :asc) }, class_name: "ActiveStorage::Attachment", as: :record, inverse_of: :record, dependent: false
end
