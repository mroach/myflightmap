json.array!(@audits) do |audit|
  json.extract! audit,
    :id,
    :auditable_type,
    :auditable_id,
    :action,
    :audited_changes,
    :version,
    :comment,
    :remote_address,
    :created_at
  json.user audit.username || audit.user.username
end
