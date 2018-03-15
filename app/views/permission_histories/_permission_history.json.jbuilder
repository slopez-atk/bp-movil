json.extract! permission_history, :id, :worker_id, :descripcion, :fecha_permiso, :fecha_eliminacion, :horas, :created_at, :updated_at
json.url permission_history_url(permission_history, format: :json)
