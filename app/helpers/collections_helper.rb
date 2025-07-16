module CollectionsHelper
  def collection_icon(collection)
    if collection.favorites?
      content_tag :i, "", class: "bi bi-heart-fill text-danger"
    else
      content_tag :i, "", class: "bi bi-collection"
    end
  end
  
  def visibility_badge(collection)
    if collection.is_public?
      content_tag :span, "Public", class: "badge bg-success"
    else
      content_tag :span, "Private", class: "badge bg-secondary"
    end
  end
  
  def user_can_edit_collection?(collection, user = current_user)
    user&.id == collection.user_id
  end
  
  def recipe_in_collection?(recipe, collection)
    collection.contains_recipe?(recipe)
  end
end
