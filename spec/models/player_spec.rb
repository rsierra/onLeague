require 'spec_helper'

describe Player do
  describe "when create" do
    context "with correct data" do
      let(:player) { create(:player) }
      subject { player }
      it { should be_valid }
    end

    context "without name" do
      let(:player) { build(:player, name: nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { player.error_on(:name).should include I18n.t('errors.messages.blank') }
    end

    context "with duplicated name" do
      let(:player) { create(:player) }
      let(:duplicate_player) { build(:player, name: player.name) }
      before { duplicate_player.valid? }
      subject { duplicate_player }
      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { duplicate_player.error_on(:name).should include I18n.t('errors.messages.taken') }
    end

    context "without born" do
      let(:player) { build(:player, born: nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:born) }
      it { player.error_on(:born).should include I18n.t('errors.messages.blank') }
    end

    context "without active" do
      let(:player) { build(:player, active: nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:active) }
      it { player.error_on(:active).should include I18n.t('errors.messages.inclusion') }
    end

    context "without eu" do
      let(:player) { build(:player, eu: nil) }
      subject { player }

      it { should_not be_valid }
      it { should have(1).error_on(:eu) }
      it { player.error_on(:eu).should include I18n.t('errors.messages.inclusion') }
    end

    context "without country" do
      let(:player) { build(:player, country: nil) }
      before { player.valid? }
      subject { player }
      it { should_not be_valid }
      it { should have(1).error_on(:country_id) }
      it { player.error_on(:country_id).should include I18n.t('errors.messages.blank') }
    end
  end

  describe "with #last_date_out" do
    context "when not have club files" do
      let(:player) { create(:player) }
      subject { player }

      its(:last_date_out) { should be_nil }
    end

    context "when have one current club file" do
      let(:player) { create(:player) }
      let(:club_file) { create(:club_file, player: player)}
      subject { player }

      its(:last_date_out) { should == club_file.date_out }
    end

    context "when have one club file with date out" do
      let(:player) { create(:player) }
      let(:club_file) { create(:club_file, player: player) }
      before { club_file.update_attributes(date_out: club_file.date_in.next) }
      subject { player }

      its(:last_date_out) { should == club_file.date_out }
    end

    context "when have club file with date out and one current" do
      let(:player) { create(:player) }
      let(:club_file) { create(:club_file, player: player)}
      before do
        club_file.update_attributes(date_out: club_file.date_in.next)
        create(:club_file, player: player, date_in: club_file.date_out.next)
      end
      subject { player }

      its(:last_date_out) { should == club_file.date_out }
    end
  end
end
