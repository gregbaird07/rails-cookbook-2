module RecipesHelper
  def star_rating(rating, max_stars = 5)
    content_tag :div, class: "text-warning" do
      (1..max_stars).map do |i|
        if i <= rating
          content_tag :i, "", class: "bi bi-star-fill"
        elsif i - 0.5 <= rating
          content_tag :i, "", class: "bi bi-star-half"
        else
          content_tag :i, "", class: "bi bi-star"
        end
      end.join.html_safe
    end
  end
  
  def rating_text(average_rating, total_reviews)
    if total_reviews > 0
      "#{average_rating} (#{total_reviews} review#{'s' if total_reviews != 1})"
    else
      "No reviews yet"
    end
  end
end
