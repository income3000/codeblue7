require "test_helper"

class OfficialRecordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @member = users(:one)
  end

  test "directory search is inaccessible until signed in" do
    get official_records_url, params: { q: "badge" }
    assert_redirected_to new_user_session_url

    post official_records_url, params: {
      official_record: {
        category: "police_officer",
        name: "Officer Example",
        city: "Springfield",
        state: "IL"
      }
    }
    assert_redirected_to new_user_session_url
    assert_equal 0, OfficialRecord.count
  end

  test "signed-in users can add and search a police officer by directory fields" do
    sign_in @member
    post official_records_url, params: {
      official_record: {
        category: "police_officer",
        name: "Jordan Example",
        city: "Springfield",
        state: "IL",
        district: "North",
        badge_number: "B-104",
        precinct: "7th",
        incident_names: "Public case 24-105",
        source_url: "https://example.org/public-record"
      }
    }

    record = OfficialRecord.find_by!(name: "Jordan Example")
    assert_equal @member, record.user
    assert_redirected_to official_record_url(record)

    get official_records_url, params: { q: "B-104", category: "police_officer", sort: "district", direction: "asc" }
    assert_response :success
    assert_select "input[type=search]"
    assert_select "a[href=?]", official_record_path(record), text: "Jordan Example"
    assert_select "th", text: "Badge"
    assert_select "th", text: "Incidents named in"
  end

  test "directory search supports attorneys and judges case history and decisions" do
    sign_in @member
    judge = OfficialRecord.create!(
      user: @member,
      category: :judge,
      name: "Casey Example",
      city: "Springfield",
      state: "IL",
      case_number: "2025-CV-17",
      history: "Civil appeal",
      decisions: "Appeal affirmed",
      source_url: "https://example.org/case"
    )

    get official_records_url, params: { q: "affirmed", category: "judge", sort: "case_number" }

    assert_response :success
    assert_select "a[href=?]", official_record_path(judge), text: "Casey Example"
    assert_select "th", text: "Case number"
    assert_select "th", text: "Decisions"
  end

  test "only the submitting member or an admin can edit directory entries" do
    sign_in @member
    record = OfficialRecord.create!(
      user: users(:two),
      category: :district_attorney,
      name: "Taylor Example",
      city: "Springfield",
      state: "IL",
      source_url: "https://example.org/attorney"
    )

    get edit_official_record_url(record)

    assert_redirected_to official_records_url
  end

  test "directory entries can be sorted by average professionalism and experience ratings" do
    sign_in @member
    high_professionalism = create_record("Rating Sort Alpha")
    high_experience = create_record("Rating Sort Beta", user: users(:two))
    unrated = create_record("Rating Sort Unrated")

    OfficialRecordReview.create!(official_record: high_professionalism, user: @member, professionalism_rating: 10, experience_rating: 2)
    OfficialRecordReview.create!(official_record: high_experience, user: users(:two), professionalism_rating: 4, experience_rating: 9)

    get official_records_url, params: { category: "judge", sort: "professionalism_rating", direction: "desc" }
    assert_response :success
    assert_ordered_records(high_professionalism, high_experience, unrated)
    assert_select "option[value=professionalism_rating]", text: "Professionalism rating"

    get official_records_url, params: { category: "judge", sort: "experience_rating", direction: "desc" }
    assert_response :success
    assert_ordered_records(high_experience, high_professionalism, unrated)
    assert_select "option[value=experience_rating]", text: "Overall experience rating"
  end

  test "official profile shows linked incidents and links to filtered incident board" do
    sign_in @member
    official = create_record("Official With Incident")
    incident = Incident.create!(user: @member, official_record: official, title: "Linked street report", description: "A related report.")

    get official_record_url(official)

    assert_response :success
    assert_select "a[href=?]", incident_path(incident), text: "Linked street report"
    assert_select "a[href=?]", incidents_path(official_record_id: official.id), text: "Browse these incidents"
  end

  private

  def create_record(name, user: @member)
    OfficialRecord.create!(user: user, category: :judge, name: name, city: "New York City", state: "New York")
  end

  def assert_ordered_records(*records)
    positions = records.map { |record| response.body.index(record.name) }
    assert positions.all?, "Expected all records in the response"
    assert_equal positions.sort, positions
  end
end
