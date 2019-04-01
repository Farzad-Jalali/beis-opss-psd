class AuditActivity::Document::Base < AuditActivity::Base
  include ActivityAttachable
  include GdprHelper
  with_attachments attachment: "document"

  private_class_method def self.from(document, investigation, title)
    activity = self.create(
      body: self.sanitize_text(document.metadata[:description]),
      source: UserSource.new(user: User.current),
      investigation: investigation,
      title: title
    )
    activity.attach_blob document
  end

  def attachment_type
    attached_image? ? "Image" : "Document"
  end

  def attached_image?
    self.attachment.image?
  end

  def sensitive_title; end

  def sensitive?
    document_is_sensitive(self.attachment, self.investigation)
  end
end
