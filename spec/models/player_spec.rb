require 'spec_helper'

describe Player do
  describe "should be valid" do
    context "with correct data" do
      let(:player) { FactoryGirl.create(:player) }
      subject { player }
      it { should be_valid }
    end
  end

  describe "should not be valid" do
    context "without name" do
      let(:player) { FactoryGirl.build(:player, :name => nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { player.error_on(:name).should include I18n.t('errors.messages.blank') }
    end

    context "without born" do
      let(:player) { FactoryGirl.build(:player, :born => nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:born) }
      it { player.error_on(:born).should include I18n.t('errors.messages.blank') }
    end

    context "without active" do
      let(:player) { FactoryGirl.build(:player, :active => nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:active) }
      it { player.error_on(:active).should include I18n.t('errors.messages.inclusion') }
    end

    context "without country" do
      let(:player) { FactoryGirl.build(:player, :country => nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:country_id) }
      it { player.error_on(:country_id).should include I18n.t('errors.messages.blank') }
    end
  end
end
