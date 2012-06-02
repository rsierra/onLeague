require 'spec_helper'

describe Substitution do
  describe "when create" do
    context "with correct data" do
      let(:substitution) { create(:substitution) }
      subject { substitution }

      it { should be_valid }
      it { substitution.class.include?(Extensions::GameEvent).should be_true }
      its(:player_relation) { should eql :player_out }
    end
  end
end
