require 'spec_helper'

describe Club do
  describe "when create" do
    context "with correct data" do
      let(:club) { build(:club) }
      subject { club }
      it { should be_valid }
    end

    context "without name" do
      let(:club) { build(:club, name: nil) }
      before { club.valid? }
      subject { club }
      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { club.error_on(:name).should include I18n.t('errors.messages.blank') }
    end

    context "with too long name" do
      let(:club) { build(:club, name: "A name more long than a 25 characters") }
      before { club.valid? }
      subject { club }
      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { club.error_on(:name).should include I18n.t('errors.messages.too_long', count: 25) }
    end

    context "with duplicate name" do
      let(:club) { build(:club, name: "Club name") }
      before do
        create(:club, name: "Club name")
        club.valid?
      end
      subject { club }
      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { club.error_on(:name).should include I18n.t('errors.messages.taken') }
    end

    context "without short_name" do
      let(:club) { build(:club, short_name: nil) }
      before { club.valid? }
      subject { club }
      it { should_not be_valid }
      it { should have(1).error_on(:short_name) }
      it { club.error_on(:short_name).should include I18n.t('errors.messages.blank') }
    end

    context "with too long short_name" do
      let(:club) { build(:club, short_name: "ABCD") }
      before { club.valid? }
      subject { club }
      it { should_not be_valid }
      it { should have(1).error_on(:short_name) }
      it { club.error_on(:short_name).should include I18n.t('errors.messages.too_long', count: 3) }
    end
  end
end
