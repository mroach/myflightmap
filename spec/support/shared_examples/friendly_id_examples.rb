RSpec.shared_examples_for 'a friendly id model' do
  let(:config) { described_class.friendly_id_config }

  it { is_expected.to have_friendly_id }
  it { is_expected.to respond_to :friendly_id }

  it "finds a #{described_class.model_name} by slug" do
    obj = create(described_class.model_name.element)
    expect(described_class.friendly.find(obj.to_param)).to be_a described_class
  end

  # These tests will fail hard if the model isn't using a slug column
  # so don't try to run them if it's not using one
  # For some reason using 'config' here doesn't work, so access directly
  context 'slug field configured', if: described_class.try(:friendly_id_config).respond_to?(:slug_column) do
    it { is_expected.to have_db_column(config.slug_column).of_type(:string) }
    it { is_expected.to have_db_index(config.slug_column).unique(true) }
  end
end
