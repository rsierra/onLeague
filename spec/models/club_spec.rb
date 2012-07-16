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
      subject { club }

      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { club.error_on(:name).should include I18n.t('errors.messages.blank') }
    end

    context "with too long name" do
      let(:club) { build(:club, name: "A name more long than a 25 characters") }
      subject { club }

      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { club.error_on(:name).should include I18n.t('errors.messages.too_long', count: 25) }
    end

    context "with duplicate name" do
      let(:club) { build(:club, name: "Club name") }
      before { create(:club, name: "Club name") }
      subject { club }

      it { should_not be_valid }
      it { should have(1).error_on(:name) }
      it { club.error_on(:name).should include I18n.t('errors.messages.taken') }
    end

    context "without short_name" do
      let(:club) { build(:club, short_name: nil) }
      subject { club }

      it { should_not be_valid }
      it { should have(1).error_on(:short_name) }
      it { club.error_on(:short_name).should include I18n.t('errors.messages.blank') }
    end

    context "with too long short_name" do
      let(:club) { build(:club, short_name: "ABCD") }
      subject { club }

      it { should_not be_valid }
      it { should have(1).error_on(:short_name) }
      it { club.error_on(:short_name).should include I18n.t('errors.messages.too_long', count: 3) }
    end
  end

  describe "when get #player_ids_on_date" do
    let(:club) { create(:club) }
    let(:player) { create(:player) }
    let(:date_in) { 1.week.ago.to_date }
    let(:date_out) { Date.tomorrow }
    let(:club_file) { create(:club_file, player: player, club: club, date_in: date_in) }

    before { club_file.update_attributes(date_out: date_out) }

    it { club.player_ids_on_date(date_in - 1.day).should be_empty }
    it { club.player_ids_on_date(date_in).should eql [player.id] }
    it { club.player_ids_on_date(date_in + 1.day).should eql [player.id] }

    context "with multiple players" do
      let(:players) { create_list(:player_with_club, 3, player_club: club) }
      let(:player_ids) { players.map(&:id).sort }
      let(:full_player_ids) { ([player.id] + players.map(&:id)).sort }
      before { players }

      it { club.player_ids_on_date(Date.yesterday).should eql full_player_ids }
      it { club.player_ids_on_date.should eql full_player_ids }
      it { club.player_ids_on_date(date_out).should eql full_player_ids }
      it { club.player_ids_on_date(date_out + 1.day).should eql player_ids }
    end
  end

  describe "when get #player_ids_in_position_on_date" do
    let(:club) { create(:club) }
    let(:player) { create(:player) }
    let(:date_in) { 1.week.ago.to_date }
    let(:date_out) { Date.tomorrow }
    let(:position) { 'defender' }
    let(:another_position) { 'goalkeeper' }
    let(:club_file) { create(:club_file, player: player, club: club, date_in: date_in, position: position) }

    before { club_file.update_attributes(date_out: date_out) }

    it { club.player_ids_in_position_on_date(position, date_in - 1.day).should be_empty }
    it { club.player_ids_in_position_on_date(position, date_in).should eql [player.id] }
    it { club.player_ids_in_position_on_date(position, date_in + 1.day).should eql [player.id] }

    it { club.player_ids_in_position_on_date(another_position).should be_empty }

    context "with multiple players" do
      let(:players) { create_list(:player_with_club, 3, player_club: club) }
      let(:player_ids) { players.map(&:id).sort }
      before { players }

      it { club.player_ids_in_position_on_date(position,Date.yesterday).should eql [player.id] }
      it { club.player_ids_in_position_on_date(position,date_out).should eql [player.id] }
      it { club.player_ids_in_position_on_date(position,date_out + 1.day).should be_empty }

      it { club.player_ids_in_position_on_date(another_position,Date.yesterday).should eql player_ids }
      it { club.player_ids_in_position_on_date.should eql player_ids }
      it { club.player_ids_in_position_on_date(another_position,date_out).should eql player_ids }
      it { club.player_ids_in_position_on_date(another_position,date_out + 1.day).should eql player_ids }
    end
  end

end
