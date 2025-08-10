module ApplicationHelper
  def nav_link_class(path)
    base_classes = "nav-link block py-2 px-3 rounded md:bg-transparent md:p-0 md:hover:bg-transparent dark:text-white dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent"
    
    if current_page?(path)
      "#{base_classes} active text-foundationprimarygreen bg-gray-50"
    else
      "#{base_classes} text-gray-700 hover:bg-gray-100"
    end
  end
  
  def nav_link_class_static
    "nav-link block py-2 px-3 text-gray-700 rounded hover:bg-gray-100 md:hover:bg-transparent md:p-0 dark:text-white dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent"
  end
end
