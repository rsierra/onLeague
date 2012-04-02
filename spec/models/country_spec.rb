require 'spec_helper'

describe Country do
  describe "should be valid" do
    context "with correct data" do
      let(:country) { FactoryGirl.build(:country) }
      subject { country }
      it { should be_valid }
    end
  end

  describe "should not be valid" do
    context "without name" do
      let(:country) { FactoryGirl.build(:country, :name => nil) }
      before { country.valid? }
      subject { country }
      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { country.error_on(:name).should include I18n.t('errors.messages.blank') }
    end

    context "without eu" do
      let(:country) { FactoryGirl.build(:country, :eu => nil) }
      before { country.valid? }
      subject { country }
      it { should_not be_valid }
      it { should have(1).error_on(:eu) }
      it { country.error_on(:eu).should include I18n.t('errors.messages.inclusion') }
    end
  end
end
