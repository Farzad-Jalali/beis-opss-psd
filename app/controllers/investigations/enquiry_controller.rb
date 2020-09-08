class Investigations::EnquiryController < Investigations::CreationFlowController
  set_attachment_names :attachment
  set_file_params_key :enquiry

  steps :coronavirus, :about_enquiry, :complainant, :complainant_details, :enquiry_details

private

  def model_key
    :enquiry
  end

  def model_params
    %i[user_title description date_received received_type coronavirus_related]
  end

  def set_investigation
    @investigation = Investigation::Enquiry.new(investigation_params).build_owner_collaborations_from(current_user)
    @investigation.set_dates_from_params(params[:enquiry])
  end

  def assign_type
    session[:enquiry][:received_type] = params[:enquiry][:received_type] == "other" ? params[:enquiry][:other_received_type] : params[:enquiry][:received_type]
  end

  def success_message
    "Enquiry was successfully created."
  end

  def set_page_title
    @page_title = "New enquiry"
    @page_subtitle = "Who did the enquiry come from?"
  end
end