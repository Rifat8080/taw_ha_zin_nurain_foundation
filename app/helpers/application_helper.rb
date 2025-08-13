module ApplicationHelper
  def nav_link_class(path)
    base_classes = "nav-link block py-2 px-3 font-medium transition-colors duration-200 lg:bg-transparent lg:p-0 lg:hover:bg-transparent"
    
    if current_page?(path)
      "#{base_classes} active text-foundationprimarygreen"
    else
      "#{base_classes} text-gray-700 hover:text-foundationprimarygreen dark:text-gray-400 dark:hover:text-white"
    end
  end
  
  def nav_link_class_static
    "nav-link block py-2 px-3 font-medium text-gray-700 hover:text-foundationprimarygreen lg:bg-transparent lg:p-0 lg:hover:bg-transparent transition-colors duration-200 dark:text-gray-400 dark:hover:text-white"
  end
end
