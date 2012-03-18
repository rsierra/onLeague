require 'spec_helper'

describe League do
  describe "should be valid" do
    context "with correct data" do
      let(:league) { FactoryGirl.build(:league) }
      subject { league }
      it { should be_valid }
    end
  end

  describe "should not be valid" do
    context "without name" do
      let(:league) { FactoryGirl.build(:league, :name => nil) }
      before { league.valid? }
      subject { league }
      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { league.error_on(:name).should include I18n.t('errors.messages.blank') }
    end

    context "with duplicate name" do
      let(:league) { FactoryGirl.build(:league, :name => "League name") }
      before do
        FactoryGirl.create(:league, :name => "League name")
        league.valid?
      end
      subject { league }
      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { league.error_on(:name).should include I18n.t('errors.messages.taken') }
    end

    context "without week" do
      let(:league) { FactoryGirl.build(:league, :week => nil) }
      before { league.valid? }
      subject { league }
      it { should_not be_valid }
      it { should have(3).error_on(:week) }
      it { league.error_on(:week).should include I18n.t('errors.messages.blank') }
      it { league.error_on(:week).should include I18n.t('errors.messages.not_a_number') }
      it { league.error_on(:week).should include I18n.t('errors.messages.too_short', :count => 1) }
    end

    context "with too long week" do
      let(:league) { FactoryGirl.build(:league, :week => 111) }
      before { league.valid? }
      subject { league }
      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { league.error_on(:week).should include I18n.t('errors.messages.too_long', :count => 2) }
    end

    context "with string week" do
      let(:league) { FactoryGirl.build(:league, :week => 'a') }
      before { league.valid? }
      subject { league }
      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { league.error_on(:week).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with float week" do
      let(:league) { FactoryGirl.build(:league, :week => '.1') }
      before { league.valid? }
      subject { league }
      it { should_not be_valid }
      it { should have(1).error_on(:week) }
      it { league.error_on(:week).should include I18n.t('errors.messages.not_an_integer') }
    end

    context "without season" do
      let(:league) { FactoryGirl.build(:league, :season => nil) }
      before { league.valid? }
      subject { league }
      it { should_not be_valid }
      it { should have(3).error_on(:season) }
      it { league.error_on(:season).should include I18n.t('errors.messages.blank') }
      it { league.error_on(:season).should include I18n.t('errors.messages.not_a_number') }
      it { league.error_on(:season).should include I18n.t('errors.messages.wrong_length', :count => 4) }
    end

    context "with too long season" do
      let(:league) { FactoryGirl.build(:league, :season => 11111) }
      before { league.valid? }
      subject { league }
      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { league.error_on(:season).should include I18n.t('errors.messages.wrong_length', :count => 4) }
    end

    context "with too short season" do
      let(:league) { FactoryGirl.build(:league, :season => 111) }
      before { league.valid? }
      subject { league }
      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { league.error_on(:season).should include I18n.t('errors.messages.wrong_length', :count => 4) }
    end

    context "with string season" do
      let(:league) { FactoryGirl.build(:league, :season => 'a') }
      before { league.valid? }
      subject { league }
      it { should_not be_valid }
      it { should have(2).error_on(:season) }
      it { league.error_on(:season).should include I18n.t('errors.messages.not_a_number') }
      it { league.error_on(:season).should include I18n.t('errors.messages.wrong_length', :count => 4) }
    end

    context "with float season" do
      let(:league) { FactoryGirl.build(:league, :season => '1111.1') }
      before { league.valid? }
      subject { league }
      it { should_not be_valid }
      it { should have(1).error_on(:season) }
      it { league.error_on(:season).should include I18n.t('errors.messages.not_an_integer') }
    end
  end
end
