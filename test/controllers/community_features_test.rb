require "test_helper"

class CommunityFeaturesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @member = users(:one)
    @admin = users(:two)
    sign_in @member
  end

  test "members can post incidents and comment" do
    assert_difference("Incident.count", 1) do
      post incidents_url, params: { incident: { title: "Street light outage", description: "The light at the corner is out.", location: "Main and 1st" } }
    end
    incident = Incident.order(:id).last
    assert_redirected_to incident_url(incident)

    assert_difference("Comment.count", 1) do
      post incident_comments_url(incident), params: { comment: { body: "I reported it to the city." } }
    end
    assert_redirected_to incident_url(incident, anchor: "comments")
  end

  test "direct messages stay limited to conversation participants" do
    post conversations_url, params: { recipient_id: @admin.id }
    conversation = Conversation.find_by!(user_one_id: [ @member.id, @admin.id ].min, user_two_id: [ @member.id, @admin.id ].max)
    assert_redirected_to conversation_url(conversation)

    assert_difference("Message.count", 1) do
      post conversation_messages_url(conversation), params: { message: { body: "Hello" } }
    end

    outsider = User.create!(email: "outsider@example.test", password: "password123", display_name: "Outsider")
    sign_out @member
    sign_in outsider
    get conversation_url(conversation)
    assert_redirected_to conversations_url
  end

  test "members cannot access administrator account management" do
    get admin_users_url
    assert_redirected_to root_url
  end

  test "administrators can change another member's role" do
    sign_out @member
    sign_in @admin

    patch admin_user_url(@member), params: { user: { role: "admin" } }

    assert_equal "admin", @member.reload.role
    assert_redirected_to admin_users_url
  end

  test "registration creates a regular member account" do
    sign_out @member

    assert_difference("User.count", 1) do
      post user_registration_url, params: {
        user: {
          display_name: "New Neighbor",
          email: "neighbor@example.test",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_equal "member", User.find_by!(email: "neighbor@example.test").role
    assert_redirected_to root_url
  end

  test "incident board requires authentication" do
    sign_out @member
    get incidents_url
    assert_redirected_to new_user_session_url
  end

  test "incident details and comments require authentication" do
    incident = Incident.create!(user: @member, title: "Road closure", description: "Road is closed near the bridge.")
    sign_out @member

    get incident_url(incident)
    assert_redirected_to new_user_session_url

    assert_no_difference("Comment.count") do
      post incident_comments_url(incident), params: { comment: { body: "I saw this too." } }
    end
    assert_redirected_to new_user_session_url
  end

  test "home page shows sign-in and sign-up links to signed-out visitors" do
    sign_out @member

    get root_url

    assert_response :success
    assert_select "body.home-page"
    assert_select "a[href=?]", new_user_session_path, text: "Sign in"
    assert_select "a[href=?]", new_user_registration_path, text: "Join the community"
    assert_select "a[href=?]", official_records_path, count: 0
  end

  test "signed-in members can access the officials directory" do
    get official_records_url

    assert_response :success
    assert_select "body.app-page"
    assert_select "input[type=search]"
  end

  test "members can associate incidents with officials and filter and sort incidents by official" do
    first_official = OfficialRecord.create!(user: @member, category: :police_officer, name: "Officer Alpha", city: "New York City", state: "New York")
    second_official = OfficialRecord.create!(user: @member, category: :judge, name: "Judge Beta", city: "New York City", state: "New York")

    post incidents_url, params: { incident: { title: "Zebra incident", description: "A report linked to the second official.", official_record_id: second_official.id } }
    post incidents_url, params: { incident: { title: "Alpha incident", description: "A report linked to the first official.", official_record_id: first_official.id } }

    assert_equal first_official, Incident.find_by!(title: "Alpha incident").official_record

    get incidents_url, params: { sort: "official" }
    assert_response :success
    assert_equal "official", request.query_parameters["sort"]
    incident_titles = response.body.scan(/<article class="incident-card">(.*?)<\/article>/m).flatten.map do |card|
      card[/<h2><a[^>]*>(.*?)<\/a><\/h2>/m, 1]
    end
    assert_equal [ "Alpha incident", "Zebra incident" ], incident_titles

    get incidents_url, params: { official_record_id: first_official.id }
    assert_response :success
    assert_select "a", text: "Alpha incident"
    assert_select "a", text: "Zebra incident", count: 0
  end
end
