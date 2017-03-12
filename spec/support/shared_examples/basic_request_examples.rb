# These examples just hit the index, show, new, and edit actions purely to make
# sure they work. This is a quick and easy way to catch basic silly errors like
# typos, nulls, things like that
RSpec.shared_context 'basic request actions' do
  let(:model) { RSpec.current_example.metadata[:model] }
  let(:model_class) { model.to_s.camelize.constantize }
  let(:factory) { model }

  before(:each) do
    sign_in_stubbed
  end

  describe '#index' do
    it 'works' do
      get polymorphic_path([model_class])
      expect(response).to have_http_status :success
    end
  end

  describe '#show' do
    it 'works' do
      record = create(factory)
      get polymorphic_path([record])
      expect(response).to have_http_status :success
    end
  end

  describe '#new' do
    it 'works' do
      get polymorphic_path([:new, model])
      expect(response).to have_http_status :success
    end
  end

  describe '#edit' do
    it 'works' do
      record = create(factory)
      get polymorphic_path([:edit, record])
      expect(response).to have_http_status :success
    end
  end
end
