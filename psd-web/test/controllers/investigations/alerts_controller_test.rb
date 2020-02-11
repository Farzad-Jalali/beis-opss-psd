require "test_helper"

class Investigations::AlertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    mock_out_keycloak_and_notify
    @investigation = load_case(:private)
    @investigation.source = sources(:investigation_private)
  end

  test "prevents creation of alert on private investigation" do
    assert_raise(Pundit::NotAuthorizedError)  { get investigation_alert_url(@investigation, id: "compose") }
  end
end
