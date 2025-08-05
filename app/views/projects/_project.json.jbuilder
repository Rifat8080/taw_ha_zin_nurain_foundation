json.extract! project, :id, :name, :categories, :description, :project_status_active, :created_at, :updated_at
json.url project_url(project, format: :json)
