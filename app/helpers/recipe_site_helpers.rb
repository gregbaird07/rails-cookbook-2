# Helper module for handling recipe sites that block automated access
module RecipeSiteHelpers
  BLOCKED_SITES = {
    'maangchi.com' => {
      name: 'Maangchi',
      instructions: [
        'Visit the recipe page in your browser',
        'Copy the recipe title from the main heading',
        'Copy the description/introduction text',
        'Look for preparation and cooking times (usually near the top)',
        'Copy each ingredient from the ingredients list',
        'Copy each instruction step from the directions section',
        'Note the serving size if mentioned'
      ],
      tips: [
        'Maangchi recipes often have video instructions - watch the video for additional details',
        'Look for ingredient substitution notes in the description',
        'Check the comments section for helpful tips from other cooks'
      ]
    }
  }.freeze

  def self.get_site_info(url)
    domain = URI.parse(url).host.downcase rescue ""
    BLOCKED_SITES.find { |site, _| domain.include?(site) }&.last
  end

  def self.manual_extraction_guide(url)
    site_info = get_site_info(url)
    return nil unless site_info

    {
      site_name: site_info[:name],
      instructions: site_info[:instructions],
      tips: site_info[:tips]
    }
  end
end
