require "rails_helper"
require "shared_contexts/oauth_token_exchange"

RSpec.describe Users::ExchangeToken do
  include_context "oauth token exchange"

  subject { described_class.call(omniauth_response: omniauth_response) }

  describe ".call", :reset_keycloak_client do
    context "when successfully exchanging the token with keycloak" do
      before do
        allow(KeycloakClient.instance)
          .to receive(:exchange_refresh_token_for_token)
                .with(refresh_token)
                .and_return(exchanged_token)
      end

      it { is_expected.to be_a_success }
      it { expect(subject.access_token).to eq(exchanged_token) }
    end

    context "when failing to exchange the refresh token" do
      before do
        allow(KeycloakClient.instance)
          .to receive(:exchange_refresh_token_for_token)
                .and_raise(exception_class)
      end

      context "when keycloak is down" do
        let(:exception_class) { Keycloak::KeycloakException }

        it { expect { subject }.to raise_error exception_class }
      end

      context "when anything else goes wrong" do
        let(:exception_class) { StandardError }

        it { is_expected.to be_a_failure }
        it { expect(subject.errors.full_messages).to eq(%w(StandardError)) }
        it do
          expect(Raven).to receive(:capture_exception).with(instance_of(StandardError))
          subject
        end
      end
    end
  end
end
