RSpec.shared_examples_for 'full read/write for' do |role|
  let(:user) { role.present? ? stubbed_user(role) : nil }

  it { is_expected.to permit_action :show }
  it { is_expected.to permit_new_and_create_actions }
  it { is_expected.to permit_edit_and_update_actions }
  it { is_expected.to permit_action :destroy }

  it 'includes a normal record' do
    expect(resolved_scope).to include record
  end
end

RSpec.shared_examples_for 'readonly for' do |role|
  let(:user) { role.present? ? stubbed_user(role) : nil }

  it { is_expected.to permit_action :index }
  it { is_expected.to permit_action :show }
  it { is_expected.to forbid_new_and_create_actions }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action :destroy }

  it 'includes a normal record' do
    expect(resolved_scope).to include record
  end
end

RSpec.shared_examples_for 'fully forbidden' do |role|
  let(:user) { role.present? ? stubbed_user(role) : nil }

  it { is_expected.to forbid_action :index }
  it { is_expected.to forbid_action :show }
  it { is_expected.to forbid_new_and_create_actions }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action :destroy }

  it 'includes no records' do
    expect(resolved_scope.all.length).to eq 0
    expect(resolved_scope.ids).not_to include record.id
    expect(resolved_scope)
  end
end
