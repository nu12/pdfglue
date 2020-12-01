module ActiveStorageAttachmentList
extend ActiveSupport::Concern

included do
    acts_as_list scope: [:record_id]
end
end

Rails.configuration.to_prepare do
ActiveStorage::Attachment.send :include, ActiveStorageAttachmentList
end