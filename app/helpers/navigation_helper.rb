
module NavigationHelper
  # Returns navigation categories with translations evaluated at runtime
  def navigation_categories
    [
      {
        name: I18n.t('navigation.category_name.palestine'),
        icon: "🇵🇸".html_safe,
        description: I18n.t('navigation.category_description.palestine'),
        route_method: :palestine_projects_path,
        filter: { categories: "Palestine" },
        count_method: :palestine_projects_count
      },
      {
        name: I18n.t('navigation.category_name.orphans'),
        icon: "👦".html_safe,
        description: I18n.t('navigation.category_description.orphans'),
        route_method: :orphan_projects_path,
        filter: { categories: "Orphan" },
        count_method: :orphan_projects_count
      },
      {
        name: I18n.t('navigation.category_name.food_water'),
        icon: "💧".html_safe,
        description: I18n.t('navigation.category_description.food_water'),
        route_method: :food_water_projects_path,
        filter: { categories: "Food & Water" },
        count_method: :food_water_projects_count
      },
      {
        name: I18n.t('navigation.category_name.crisis_relief'),
        icon: "🌍".html_safe,
        description: I18n.t('navigation.category_description.crisis_relief'),
        route_method: :crisis_projects_path,
        filter: { categories: "Crisis" },
        count_method: :crisis_projects_count
      },
      {
        name: I18n.t('navigation.category_name.pay_zakat'),
        icon: "💰".html_safe,
        description: I18n.t('navigation.category_description.pay_zakat'),
        route_method: :zakat_calculations_path,
        is_zakat: true,
        count_method: :zakat_eligible_count
      },
      {
        name: I18n.t('navigation.category_name.sadaqah'),
        icon: "🤲".html_safe,
        description: I18n.t('navigation.category_description.sadaqah'),
        route_method: :sadaqah_projects_path,
        filter: { categories: "Sadaqah" },
        count_method: :sadaqah_projects_count
      },
      {
        name: I18n.t('navigation.category_name.healthcare'),
        icon: "🏥".html_safe,
        description: I18n.t('navigation.category_description.healthcare'),
        route_method: :healthcare_requests_path,
        is_healthcare: true,
        count_method: :active_healthcare_requests_count
      },
      {
        name: I18n.t('navigation.category_name.education'),
        icon: "📚".html_safe,
        description: I18n.t('navigation.category_description.education'),
        route_method: :education_projects_path,
        filter: { categories: "Education" },
        count_method: :education_projects_count
      },
      {
        name: I18n.t('navigation.category_name.emergency'),
        icon: "🚨".html_safe,
        description: I18n.t('navigation.category_description.emergency'),
        route_method: :emergency_projects_path,
        filter: { categories: "Emergency" },
        count_method: :emergency_projects_count
      },
      {
        name: I18n.t('navigation.category_name.community'),
        icon: "🤝".html_safe,
        description: I18n.t('navigation.category_description.community'),
        route_method: :community_projects_path,
        filter: { categories: "Community" },
        count_method: :community_projects_count
      },
      {
        name: I18n.t('navigation.category_name.events'),
        icon: "🗓️".html_safe,
        description: I18n.t('navigation.category_description.events'),
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
        url: category[:is_zakat] ? zakat_calculator_url :
             category[:is_healthcare] ? healthcare_requests_path :
             category[:is_events] ? events_path :
             projects_path(filter: category[:filter])
      )
    end
  end

  # Dynamic count methods
  def palestine_projects_count
    Project.active.where("categories ILIKE ?", "%Palestine%").count
  end

  def orphan_projects_count
    Project.active.where("categories ILIKE ?", "%Orphan%").count
  end

  def food_water_projects_count
    Project.active.where("categories ILIKE ? OR categories ILIKE ?", "%Food%", "%Water%").count
  end

  def crisis_projects_count
    Project.active.where("categories ILIKE ?", "%Crisis%").count
  end

  def sadaqah_projects_count
    Project.active.where("categories ILIKE ?", "%Sadaqah%").count
  end

  def education_projects_count
    Project.active.where("categories ILIKE ?", "%Education%").count
  end

  def emergency_projects_count
    Project.active.where("categories ILIKE ?", "%Emergency%").count
  end

  def community_projects_count
    Project.active.where("categories ILIKE ?", "%Community%").count
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
