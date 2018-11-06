module DocumentsHelper
  include FileConcern

  def associated_documents_path(parent)
    polymorphic_path([parent, :documents])
  end

  def associated_document_path(parent, document)
    associated_documents_path(parent) + "/" + document.id.to_s
  end

  def new_associated_document_path(parent)
    associated_documents_path(parent) + "/new"
  end

  def new_document_flow_path(parent)
    associated_documents_path(parent) + "/new/new"
  end

  def edit_associated_document_path(parent, document)
    associated_document_path(parent, document) + "/edit"
  end

  def document_type_label(document_type)
    case document_type
    when :correspondence_originator
      "Correspondence from originator"
    when :correspondence_business
      "Correspondence from business"
    when :correspondence_other
      "Correspondence from other"
    when :tech_specs
      "Technical specifications"
    when :test_results
      "Test results"
    when :risk_assessment
      "Risk assessment"
    else
      "Other"
    end
  end

  def document_filetype_label(document)
    return "Audio" if document.audio?
    return "Image" if document.image?
    return "Video" if document.video?
    return "Text"  if document.text?

    case document.content_type
    when "application/pdf"
      "PDF"
    when "application/msword",
         "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "Word Document"
    when "application/vnd.ms-excel",
         "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "Excel Document"
    when "application/vnd.ms-powerpoint",
         "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "PowerPoint Document"
    else
      document_file_extension(document).upcase
    end
  end

  def document_file_extension(document)
    File.extname(document.filename.to_s)&.remove(".")&.upcase
  end

  def set_parent
    @parent = Investigation.find(params[:investigation_id]) if params[:investigation_id]
    @parent = Product.find(params[:product_id]) if params[:product_id]
  end

  def save_document
    document = attach_file_to_list(@document_blob, @parent.documents)
    AuditActivity::Document::Add.from(document, @parent) if @parent.class == Investigation
    redirect_to @parent
  end

  def get_file_params_key
    :document
  end
end
