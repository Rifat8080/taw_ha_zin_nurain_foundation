
module NavigationHelper
  # Returns navigation categories with translations evaluated at runtime
  def navigation_categories
    [
      {
        name: I18n.t("navigation.category_name.palestine"),
        icon: "🇵🇸".html_safe,
        description: I18n.t("navigation.category_description.palestine"),
        route_method: :palestine_projects_path,
        filter: { categories: "Palestine" },
        count_method: :palestine_projects_count
      },
      {
        name: I18n.t("navigation.category_name.orphans"),
        icon: "👦".html_safe,
        description: I18n.t("navigation.category_description.orphans"),
        route_method: :orphan_projects_path,
  filter: { categories: "Orphans" },
        count_method: :orphan_projects_count
      },
      {
        name: I18n.t("navigation.category_name.food_water"),
        icon: "💧".html_safe,
        description: I18n.t("navigation.category_description.food_water"),
        route_method: :food_water_projects_path,
  filter: { categories: "Food&Water" },
  count_method: :food_water_projects_count
      },
      {
        name: I18n.t("navigation.category_name.crisis_relief"),
        icon: "🌍".html_safe,
        description: I18n.t("navigation.category_description.crisis_relief"),
        route_method: :crisis_projects_path,
  filter: { categories: "Crisis_Relief" },
  count_method: :crisis_projects_count
      },
      {
        name: I18n.t("navigation.category_name.pay_zakat"),
        icon: "💰".html_safe,
        description: I18n.t("navigation.category_description.pay_zakat"),
        route_method: :zakat_calculations_path,
        is_zakat: true,
        count_method: :zakat_eligible_count
      },
      {
        name: I18n.t("navigation.category_name.sadaqah"),
        icon: "🤲".html_safe,
        description: I18n.t("navigation.category_description.sadaqah"),
        route_method: :sadaqah_projects_path,
        filter: { categories: "Sadaqah" },
        count_method: :sadaqah_projects_count
      },
      {
        name: I18n.t("navigation.category_name.healthcare"),
        icon: "🏥".html_safe,
        description: I18n.t("navigation.category_description.healthcare"),
        route_method: :healthcare_requests_path,
        is_healthcare: true,
        count_method: :active_healthcare_requests_count
      },
      {
        name: I18n.t("navigation.category_name.education"),
        icon: "📚".html_safe,
        description: I18n.t("navigation.category_description.education"),
        route_method: :education_projects_path,
        filter: { categories: "Education" },
        count_method: :education_projects_count
      },
      {
        name: I18n.t("navigation.category_name.emergency"),
        icon: "🚨".html_safe,
        description: I18n.t("navigation.category_description.emergency"),
        route_method: :emergency_projects_path,
        filter: { categories: "Emergency" },
        count_method: :emergency_projects_count
      },
      {
        name: I18n.t("navigation.category_name.community"),
        icon: "🤝".html_safe,
        description: I18n.t("navigation.category_description.community"),
        route_method: :community_projects_path,
        filter: { categories: "Community" },
        count_method: :community_projects_count
      },
      {
        name: I18n.t("navigation.category_name.events"),
        icon: "🗓️".html_safe,
        description: I18n.t("navigation.category_description.events"),
        route_method: :events_path,
        is_events: true,
        count_method: :upcoming_events_count
      }
    ]
  end

  # Get navigation categories with dynamic counts and runtime translations
  def navigation_categories_with_counts
    navigation_categories.map do |category|
      category.merge(
        count: send(category[:count_method]),
        url: category_url_for(category)
      )
    end
  end

  def category_url_for(category)
    base_url = if category[:is_zakat]
      zakat_calculator_url
    elsif category[:is_healthcare]
      healthcare_requests_path
    elsif category[:is_events]
      events_path
    else
      projects_path(filter: category[:filter])
    end

    # If the current session is in authenticated mode, preserve that layout
    # when generating URLs for shared resources so clicks from the dashboard
    # keep the authenticated UI.
    if session[:layout_mode] == 'authenticated' && user_signed_in?
      uri = URI.parse(base_url)
      # Append layout param safely
      query = Rack::Utils.parse_nested_query(uri.query).merge('layout' => 'authenticated')
      uri.query = query.to_query
      uri.to_s
    else
      base_url
    end
  end

  # Dynamic count methods
  def palestine_projects_count
  Project.active.by_category('Palestine').count
  end

  def orphan_projects_count
  Project.active.by_category('Orphans').count
  end

  def food_water_projects_count
  # Stored category is 'Food&Water' — allow fallback matches for legacy entries
  Project.active.by_category('Food&Water').count
  end

  def crisis_projects_count
  Project.active.by_category('Crisis_Relief').count
  end

  def sadaqah_projects_count
  Project.active.by_category('Sadaqah').count
  end

  def education_projects_count
  Project.active.by_category('Education').count
  end

  def emergency_projects_count
  Project.active.by_category('Emergency').count
  end

  def community_projects_count
  Project.active.by_category('Community').count
  end

  def zakat_eligible_count
    return 0 unless user_signed_in?
    current_user.zakat_calculations.where("zakat_due > 0").count
  end

  def active_healthcare_requests_count
    HealthcareRequest.visible_to_public.count
  end

  def upcoming_events_count
    Event.upcoming.count
  end

  private

  def zakat_calculator_url
    zakat_calculations_path
  end
end
