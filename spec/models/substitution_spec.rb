require 'spec_helper'

describe Substitution do
  describe "when create" do
    context "with correct data" do
      let(:substitution) { create(:substitution) }
      subject { substitution }

      it { should be_valid }
      it { substitution.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :player_out }
      its(:second_player_relation) { should eql :player_in }
    end

    context "without player in" do
      let(:substitution) { build(:substitution, player_in: nil) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:player_in) }
      it { substitution.error_on(:player_in).should include I18n.t('errors.messages.blank') }
    end

    context "without minute" do
      let(:substitution) { build(:substitution, minute: nil) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(2).error_on(:minute) }
      it { substitution.error_on(:minute).should include I18n.t('errors.messages.blank') }
      it { substitution.error_on(:minute).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with minute less than 0" do
      let(:substitution) { build(:substitution, minute: -1) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { substitution.error_on(:minute).should include I18n.t('errors.messages.greater_than_or_equal_to', :count => 0) }
    end

    context "with minute greater than 130" do
      let(:substitution) { build(:substitution, minute: 131) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { substitution.error_on(:minute).should include I18n.t('errors.messages.less_than_or_equal_to', :count => 130) }
    end

    context "with not integer minute" do
      let(:substitution) { build(:substitution, minute: 10.1) }
      subject { substitution }

      it { should_not be_valid }
      it { should have(1).error_on(:minute) }
      it { substitution.error_on(:minute).should include I18n.t('errors.messages.not_an_integer') }
    end
  end
end
