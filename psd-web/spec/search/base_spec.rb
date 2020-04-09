require "rails_helper"

begin
  Search::Base
rescue LoadError
end
begin
Search::Form
rescue LoadError
end

RSpec.describe Search::Base, :with_elasticsearch do
  let(:team1) { create(:team) }
  let(:user11) { create(:user, teams: [team1]) }
  let(:user12) { create(:user, teams: [team1]) }

  let(:team2) { create(:team) }
  let(:user21) { create(:user, teams: [team2]) }
  let(:user22) { create(:user, teams: [team2]) }

  let(:allegation1) { create(:allegation, assignable: team1) }
  let(:allegation2) { create(:allegation, is_closed: true,  assignable: user11) }
  let(:enquiry1)    { create(:enquiry, assignable: team1) }
  let(:enquiry2)    { create(:enquiry, is_closed: true,  assignable: user12 ) }
  let(:project1)    { create(:project, assignable: team2) }
  let(:project2)    { create(:project, is_closed: true, assignable: user22) }

  let(:source1) { create(:user_source, user: user11, sourceable: allegation1) }
  let(:source2) { create(:user_source, user: user11, sourceable: allegation2) }
  let(:source3) { create(:user_source, user: user12, sourceable: enquiry1) }
  let(:source4) { create(:user_source, user: user21, sourceable: enquiry2) }
  let(:source5) { create(:user_source, user: user21, sourceable: project1) }
  let(:source6) { create(:user_source, user: user22, sourceable: project2) }

  let(:unchecked) { "unchecked" }
  let(:checked) { "checked" }

  let(:assigned_to_me) { unchecked }
  let(:assigned_to_someone_else) { unchecked }
  let(:assigned_to_someone_else_id) { unchecked }
  let(:assigned_to_team_0) { unchecked }

  let(:created_by_me) { unchecked }
  let(:created_by_someone_else) { unchecked }
  let(:created_by_someone_else_id) { unchecked }
  let(:created_by_team_0) { unchecked }

  let(:allegation) { unchecked }
  let(:enquiry) { unchecked }
  let(:project) { unchecked }

  let(:status_open) { checked }
  let(:status_closed) { checked }

  let(:sort_by) { unchecked }

  let(:params) do
    {
      "assigned_to_me"=> assigned_to_me,
      "assigned_to_someone_else"=> assigned_to_someone_else,
      "assigned_to_someone_else_id"=> assigned_to_someone_else_id,
      "assigned_to_team_0"=> assigned_to_team_0,

      "created_by_me"=> created_by_me,
      "created_by_someone_else"=> created_by_someone_else,
      "created_by_someone_else_id"=> created_by_someone_else_id,
      "created_by_team_0"=> created_by_team_0,

      "allegation"=>allegation,
      "enquiry"=>enquiry,
      "project"=>project,

      "status_closed"=>status_closed,
      "status_open"=>status_open,

      "sort_by"=>sort_by
    }
  end

  before do
    mailer = double
    allow(mailer).to receive(:deliver_later)
    allow(NotifyMailer).to receive(:investigation_updated).and_return(mailer)

    investigations = []
    investigations << allegation1
    investigations << allegation2
    investigations << enquiry1
    investigations << enquiry2
    investigations << project1
    investigations << project2

    source1
    source2
    source3
    source4
    source5
    source6

    investigations.map(&:reload)
  end

  let(:search_form)   { Search::Form.new(params) }
  let(:search_engine) { Search::Base.new(search_form) }

  shared_examples_for "search" do
    it "return correct products" do
      expect(search_engine.search.map(&:id)).to eq(expected_products.map(&:id))
    end
  end

  it_should_behave_like "search" do
    let(:status_closed) { unchecked }
    let(:expected_products) do
      [ project1, enquiry1, allegation1, ]
    end
  end

  context "include all cases" do
    it_should_behave_like "search" do
      let(:expected_products) do
        [ project2, project1, enquiry2, enquiry1, allegation2, allegation1, ]
      end
    end
  end

  describe "Created by filter" do
    # let(:source3) { create(:user_source, user: user12, sourceable: enquiry1) }

    context "by me" do
      it_should_behave_like "search" do
        let(:created_by_me) { user11.id }
        let(:expected_products) do
          [ allegation2, allegation1, ]
        end
      end
    end

    context "by my team" do
      it_should_behave_like "search" do
        let(:created_by_team_0) { team1.id }
        let(:expected_products) do
          [ enquiry1, allegation2, allegation1, ]
        end
      end
    end

    context "by other" do
      let(:created_by_someone_else) { checked }

      context "team" do
        it_should_behave_like "search" do
          let(:created_by_someone_else_id) { team1.id }
          let(:expected_products) do
            [ enquiry1, allegation2, allegation1, ]
          end
        end
      end

      context "by user" do
        it_should_behave_like "search" do
          let(:created_by_someone_else_id) { user11.id }
          let(:expected_products) do
            [ allegation2, allegation1, ]
          end
        end
      end
    end

    context "all checked" do
      it_should_behave_like "search" do
        let(:created_by_me) { user11.id }
        let(:created_by_team_0) { team1.id }
        let(:created_by_someone_else) { checked }
        let(:created_by_someone_else_id) { team2.id }

        let(:expected_products) do
          [ project2, project1, enquiry2, enquiry1, allegation2, allegation1, ]
        end
      end
    end
  end

  context "By type" do
    context "project and allegation" do
      it_should_behave_like "search" do
        let(:project) { checked }
        let(:allegation) { checked }
        let(:expected_products) do
          [ project2, project1, allegation2, allegation1]
        end
      end
    end

    context "project" do
      it_should_behave_like "search" do
        let(:project) { checked }
        let(:expected_products) do
          [ project2, project1, ]
        end
      end
    end

    context "allegation" do
      it_should_behave_like "search" do
        let(:allegation) { checked }
        let(:expected_products) do
          [ allegation2, allegation1, ]
        end
      end
    end

    context "enquiry" do
      it_should_behave_like "search" do
        let(:enquiry) { checked }
        let(:expected_products) do
          [  enquiry2, enquiry1, ]
        end
      end
    end
  end

  context "Assignee" do
    context "to me" do
      it_should_behave_like "search" do
        let(:assigned_to_me) { user11.id }

        let(:expected_products) do
          [  allegation1 ]
        end
      end
    end

    context "to my team" do
      it_should_behave_like "search" do
        let(:assigned_to_me) { team1.id }

        let(:expected_products) do
          [  enquiry2, enquiry1, allegation2, allegation1 ]
        end
      end
    end

    context "other" do
      let(:assigned_to_someone_else) { checked }

      context "to me" do
        it_should_behave_like "search" do
          let(:assigned_to_someone_else_id) { user11.id }

          let(:expected_products) do
            [  allegation1 ]
          end
        end
      end

      context "to my team" do
        it_should_behave_like "search" do
          let(:assigned_to_someone_else_id) { team1.id }

          let(:expected_products) do
            [  enquiry2, enquiry1, allegation2, allegation1 ]
          end
        end
      end
    end
  end
end
