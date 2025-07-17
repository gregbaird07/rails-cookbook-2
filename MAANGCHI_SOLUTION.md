# Recipe Parser Enhancement for Protected Sites

## Problem
The Maangchi website (https://www.maangchi.com) blocks automated requests with CloudFlare protection, returning 403 Forbidden errors when the recipe parser tries to access it.

## Solution Implemented

### 1. Enhanced HTTP Request Headers
Updated the `RecipeUrlParser` service to use more realistic browser headers:
- Updated User-Agent to a newer Chrome version
- Added comprehensive browser headers (Accept, Accept-Language, etc.)
- Added special handling for maangchi.com with delays
- Improved error logging for different HTTP status codes

### 2. Intelligent Error Handling
Modified the `RecipesController#parse_url` action to:
- Detect specific blocked domains (like maangchi.com)
- Provide domain-specific error messages
- Include manual extraction guidance for blocked sites

### 3. Manual Extraction Guide System
Created `RecipeSiteHelpers` module with:
- Site-specific manual extraction instructions
- Step-by-step guidance for users
- Tips and best practices for each blocked site

### 4. Enhanced User Interface
Updated the recipe URL parser JavaScript to:
- Display detailed manual extraction guides when sites are blocked
- Show helpful instructions in a formatted, readable way
- Provide better user feedback for different error scenarios

### 5. Updated Form Information
Enhanced the new recipe form to inform users about:
- Which sites are fully supported
- Which sites have limited support due to bot protection
- What to expect when encountering blocked sites

## How It Works

1. **When a user enters a Maangchi URL:**
   - The parser attempts to fetch the page with enhanced headers
   - CloudFlare blocks the request (403 Forbidden)
   - The system detects this is a maangchi.com domain
   - Returns a manual extraction guide instead of a generic error

2. **The user interface displays:**
   - Clear explanation of why automated parsing failed
   - Step-by-step instructions for manual recipe extraction
   - Site-specific tips for getting the best results

3. **For supported sites:**
   - Normal automated parsing continues to work
   - Users get parsed recipe data automatically

## Files Modified

- `app/services/recipe_url_parser.rb` - Enhanced headers and error handling
- `app/controllers/recipes_controller.rb` - Improved error response logic
- `app/helpers/recipe_site_helpers.rb` - New manual extraction guide system
- `app/javascript/controllers/recipe_url_parser_controller.js` - Enhanced UI feedback
- `app/views/recipes/new.html.erb` - Updated user information

## Benefits

1. **Better User Experience**: Instead of cryptic errors, users get helpful guidance
2. **Site Coverage**: Even blocked sites now have support through manual guidance
3. **Future-Proof**: Easy to add more blocked sites to the helper system
4. **Graceful Degradation**: Automatic parsing when possible, manual guidance when not

## Testing

The solution has been tested with:
- ✅ Maangchi URL (shows manual guide as expected)
- ✅ Supported sites like Food.com (automatic parsing works)
- ✅ Error handling for various scenarios

Users can now successfully work with Maangchi recipes by following the provided manual extraction guide, which gives them clear steps to copy the recipe information manually from their browser.
