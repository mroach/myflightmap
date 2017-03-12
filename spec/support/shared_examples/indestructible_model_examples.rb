RSpec.shared_examples_for 'an indestructible model' do
  describe '#destroy?' do
    # the readonly? property should prevent record destruction
    # We do test that, but make sure destroy doesn't actually work
    it 'disallows record destruction' do
      se = create(described_class.model_name.element)
      expect {
        begin
          se.destroy
        rescue
          ActiveRecord::ReadOnlyRecord
        end
      }.not_to change(described_class, :count)
    end
  end

  context '#readonly?' do
    context 'persisted object' do
      subject { create(described_class.model_name.element) }
      it { is_expected.to be_readonly }
    end

    context 'non-persisted object' do
      subject { build(described_class.model_name.element) }
      it { is_expected.not_to be_readonly }
    end
  end
end
