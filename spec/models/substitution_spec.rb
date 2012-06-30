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
      it { should have(2).error_on(:player_in) }
      it { substitution.error_on(:player_in).should include I18n.t('errors.messages.blank') }
      it { substitution.error_on(:player_in).should include I18n.t('activerecord.errors.models.substitution.attributes.player_in.should_not_play_yet') }
    end
  end
end
