class NanomaterialBuildController < ApplicationController
  include Wicked::Wizard

  steps :select_purpose, :confirm_restrictions, :confirm_usage, :unhappy_path

  before_action :set_component
  before_action :set_nano_element
  before_action :set_purpose, if: -> { step == :confirm_restrictions }

  def show
    if step == :confirm_restrictions && non_standard_purpose?(@purpose)
      return redirect_to wizard_path(:unhappy_path)
    end

    render_wizard
  end

  def update
    case step
    when :select_purpose
      render_select_purpose_step
    when :confirm_restrictions
      render_confirm_restrictions_step
    when :confirm_usage
      render_confirm_usage_step
    end
  end

  def new
    redirect_to wizard_path(steps.first)
  end

  def previous_wizard_path
    case step
    when :select_purpose
      responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, :list_nanomaterials)
    when :confirm_usage, :unhappy_path
      wizard_path(:select_purpose)
    else
      super
    end
  end

  def finish_wizard_path
    next_nano_element = get_next_nano_element
    if next_nano_element.present?
      new_responsible_person_notification_component_nanomaterial_build_path(@component.notification.responsible_person, @component.notification, @component, next_nano_element)
    else
      responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, :select_category)
    end
  end

private

  def set_component
    @component = Component.find(params[:component_id])
    authorize @component.notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end

  def set_nano_element
    @nano_element = NanoElement.find(params[:nanomaterial_nano_element_id])
  end

  def set_purpose
    @purpose = params[:purpose]
  end

  def render_select_purpose_step
    selected_purpose = params.dig(:nano_element, :purpose)
    if selected_purpose.present?
      redirect_to wizard_path(:confirm_restrictions, purpose: selected_purpose)
    else
      @nano_element.errors.add :purpose, "Select an option"
      render step
    end
  end

  def render_confirm_restrictions_step
    confirm_restrictions = params.dig(:nano_element, :confirm_restrictions)
    if confirm_restrictions == "true"
      render_wizard @nano_element
    elsif confirm_restrictions == "false"
      redirect_to wizard_path(:unhappy_path)
    else
      @nano_element.errors.add :confirm_restrictions, "Select an option"
      render step
    end
  end

  def render_confirm_usage_step
    confirm_usage = params.dig(:nano_element, :confirm_usage)
    if confirm_usage == "true"
      redirect_to finish_wizard_path
    elsif confirm_usage == "false"
      redirect_to wizard_path(:unhappy_path)
    else
      @nano_element.errors.add :confirm_usage, "Select an option"
      render step
    end
  end

  def get_next_nano_element
    @nano_element.nano_material.nano_elements.each_cons(2) do |element, next_element|
      return next_element if element == @nano_element
    end
  end

  def non_standard_purpose?(purpose)
    %w(colorant preservative uv_filter).exclude?(purpose)
  end
end
