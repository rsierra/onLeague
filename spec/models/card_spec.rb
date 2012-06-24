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

    context "without kind" do
      let(:card) { build(:card, kind: nil) }
      subject { card }

      it { should_not be_valid }
      it { should have(2).error_on(:kind) }
      it { card.error_on(:kind).should include I18n.t('errors.messages.blank') }
      it { card.error_on(:kind).should include I18n.t('errors.messages.inclusion') }
    end
  end

  context "when get red cards" do
    let(:card) { create(:card) }
    let(:red_card) { create(:red_card) }

    before { card; red_card }

    it { Card.red.should == [red_card] }
  end
end