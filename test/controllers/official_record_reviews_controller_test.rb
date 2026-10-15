require "test_helper"

class OfficialRecordReviewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @member = users(:one)
    @official = OfficialRecord.create!(
      user: @member,
      category: :judge,
      name: "Morgan Example",
      city: "Springfield",
      state: "IL",
      case_number: "CV-2026-8",
      source_url: "https://example.org/official-record"
    )
  end

  test "members can rate professionalism and overall experience and update their own rating" do
    sign_in @member
    assert_difference("OfficialRecordReview.count", 1) do
      post official_record_reviews_url(@official), params: {
        official_record_review: { professionalism_rating: 8, experience_rating: 7, comment: "Clear communication." }
      }
    end

    review = OfficialRecordReview.find_by!(user: @member, official_record: @official)
    assert_redirected_to official_record_url(@official)

    assert_no_difference("OfficialRecordReview.count") do
      post official_record_reviews_url(@official), params: {
        official_record_review: { professionalism_rating: 9, experience_rating: 8, comment: "Updated after follow-up." }
      }
    end
    assert_equal 9, review.reload.professionalism_rating
    assert_equal 8, review.experience_rating

    get official_record_url(@official)
    assert_response :success
    assert_select "dd", text: "9.0 / 10"
    assert_select "dd", text: "8.0 / 10"

    sign_out @member
    sign_in users(:two)
    post official_record_reviews_url(@official), params: {
      official_record_review: { professionalism_rating: 7, experience_rating: 6 }
    }

    get official_record_url(@official)
    assert_select "dd", text: "8.0 / 10"
    assert_select "dd", text: "7.0 / 10"
    assert_select "dd", text: "2", count: 1
  end

  test "rating submissions require sign-in" do
    assert_no_difference("OfficialRecordReview.count") do
      post official_record_reviews_url(@official), params: {
        official_record_review: { professionalism_rating: 10, experience_rating: 10 }
      }
    end
    assert_redirected_to new_user_session_url
  end

  test "ratings must be between one and ten" do
    sign_in @member

    assert_no_difference("OfficialRecordReview.count") do
      post official_record_reviews_url(@official), params: {
        official_record_review: { professionalism_rating: 0, experience_rating: 11 }
      }
    end
    assert_redirected_to official_record_url(@official)
  end

  test "members cannot delete another member's rating" do
    review = OfficialRecordReview.create!(
      official_record: @official,
      user: users(:two),
      professionalism_rating: 5,
      experience_rating: 6
    )
    sign_in @member

    assert_no_difference("OfficialRecordReview.count") do
      delete official_record_review_url(@official, review)
    end
    assert_redirected_to official_record_url(@official)
  end
end
