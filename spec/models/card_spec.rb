require 'spec_helper'

describe Card do
  describe "when create" do
    context "with correct data" do
      let(:card) { create(:card) }
      subject { card }

      it { should be_valid }
      it { card.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :player }
    end

    context "without minute" do
      let(:card) { build(:card, minute: nil) }
      subject { card }

      it { should_not be_valid }
      it { should have(2).error_on(:minute) }
      it { card.error_on(:minute).should include I18n.t('errors.messages.blank') }
      it { card.error_on(:minute).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with minute less than 0" do
      let(:card) { build(:card, minute: -1) }
      subject { card }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { card.error_on(:minute).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
    end

    context "with minute greater than 130" do
      let(:card) { build(:card, minute: 131) }
      subject { card }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { card.error_on(:minute).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 130) }
    end

    context "with not integer minute" do
      let(:card) { build(:card, minute: 10.1) }
      subject { card }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { card.error_on(:minute).should include I18n.t('errors.messages.not_an_integer') }
    end

    context "without kind" do
      let(:card) { build(:card, kind: nil) }
      subject { card }

      it { should_not be_valid }
      it { should have(2).error_on(:kind) }
      it { card.error_on(:kind).should include I18n.t('errors.messages.blank') }
      it { card.error_on(:kind).should include I18n.t('errors.messages.inclusion') }
    end
  end
end