RSpec.shared_context 'a resource controller' do |extra_options|
  let(:model_class) { described_class.name.sub(/Controller$/, '').singularize.constantize }
  let(:resource_key) { model_class.model_name.singular }

  # For UPDATE and DELETE operations we need a record to exist
  # Create one that we can update or destroy
  let(:record) { create(resource_key) }

  # If the controller is shallow nested under a parent, the implementing
  # controller spec must a define a parent_method block that returns the
  # parameter key and value of the parent record
  # For example if we're testing skills nested under a person, the controller
  # would have :
  #
  # let(:parent_record) { [:person_id, create(:person).id] }
  #
  # The routes.rb would look like:
  #
  # resources :people, shallow: true do
  #   resources :skills
  # end
  let(:payload) {
    data = {}
    if defined?(parent_record)
      key, id = parent_record
      data[key] = id
    end
    data
  }

  before(:each) do
    sign_in_stubbed
  end

  describe 'POST #create', unless: (extra_options || {}).fetch(:except, []).include?(:create) do
    context 'with valid params' do
      it 'creates a new record' do
        params = payload
        params[resource_key] = valid_attributes
        expect {
          post :create, params: params
        }.to change(model_class, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'creates no new record' do
        params = payload
        params[resource_key] = invalid_attributes
        expect {
          post :create, params: params
        }.not_to change(model_class, :count)
      end
    end
  end

  describe 'PUT #update', unless: (extra_options || {}).fetch(:except, []).include?(:update) do
    context 'with valid params' do
      it 'updates the record' do
        put :update, params: Hash['id', record.to_param, resource_key, new_attributes]
        record.reload
        new_attributes.each do |k, v|
          actual = record.send(k)
          expect(actual).to eq(v), "expected #{k} to eq #{v} but was #{actual}"
        end
      end
    end

    context 'with invalid params' do
      it 'does not update the record' do
        put :update, params: Hash['id', record.to_param, resource_key, invalid_attributes]
        record.reload
        invalid_attributes.each do |k, v|
          expect(record.send(k)).not_to eq v
        end
      end
    end
  end

  describe 'DELETE #destroy', unless: (extra_options || {}).fetch(:except, []).include?(:destroy) do
    it 'destroys the requested record' do
      # Load the id outside of the expect block to force the record to be
      # created, otherwise rspec can't detect the change
      id = record.to_param
      expect {
        delete :destroy, params: { id: id }
      }.to change(model_class, :count).by(-1)
    end
  end
end
