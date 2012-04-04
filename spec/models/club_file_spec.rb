require 'spec_helper'

describe ClubFile do
  describe "when create" do
    context "with correct data" do
      let(:club_file) { create(:club_file) }
      subject { club_file }
      it { should be_valid }
    end

    context "with correct data and out" do
      let(:club_file) { create(:club_file_with_out) }
      subject { club_file }
      it { should be_valid }
    end

    context "without club" do
      let(:club_file) { build(:club_file, club: nil) }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:club_id) }
      it { club_file.error_on(:club_id).should include I18n.t('errors.messages.blank') }
    end

    context "without player" do
      let(:club_file) { build(:club_file, player: nil) }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:player_id) }
      it { club_file.error_on(:player_id).should include I18n.t('errors.messages.blank') }
    end

    context "without number" do
      let(:club_file) { build(:club_file, number: nil) }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(2).error_on(:number) }
      it { club_file.error_on(:number).should include I18n.t('errors.messages.blank') }
      it { club_file.error_on(:number).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with wrong number" do
      let(:club_file) { build(:club_file, number: 'a') }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:number) }
      it { club_file.error_on(:number).should include I18n.t('errors.messages.not_a_number') }
    end

    context "without position" do
      let(:club_file) { build(:club_file, position: nil) }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(2).error_on(:position) }
      it { club_file.error_on(:position).should include I18n.t('errors.messages.blank') }
      it { club_file.error_on(:position).should include I18n.t('errors.messages.inclusion') }
    end

    context "without value" do
      let(:club_file) { build(:club_file, value: nil) }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(2).error_on(:value) }
      it { club_file.error_on(:value).should include I18n.t('errors.messages.blank') }
      it { club_file.error_on(:value).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with wrong value" do
      let(:club_file) { build(:club_file, value: 'a') }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:value) }
      it { club_file.error_on(:value).should include I18n.t('errors.messages.not_a_number') }
    end

    context "without week_in" do
      let(:club_file) { build(:club_file, week_in: nil) }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(2).error_on(:week_in) }
      it { club_file.error_on(:week_in).should include I18n.t('errors.messages.blank') }
      it { club_file.error_on(:week_in).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with wrong week_in" do
      let(:club_file) { build(:club_file, week_in: 'a') }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:week_in) }
      it { club_file.error_on(:week_in).should include I18n.t('errors.messages.not_a_number') }
    end

    context "without season_in" do
      let(:club_file) { build(:club_file, season_in: nil) }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(2).error_on(:season_in) }
      it { club_file.error_on(:season_in).should include I18n.t('errors.messages.blank') }
      it { club_file.error_on(:season_in).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with wrong season_in" do
      let(:club_file) { build(:club_file, season_in: 'a') }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:season_in) }
      it { club_file.error_on(:season_in).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with wrong week_out" do
      let(:club_file) { build(:club_file, week_out: 'a') }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:week_out) }
      it { club_file.error_on(:week_out).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with wrong season_out" do
      let(:club_file) { build(:club_file, season_out: 'a') }
      before { club_file.valid? }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:season_out) }
      it { club_file.error_on(:season_out).should include I18n.t('errors.messages.not_a_number') }
    end
  end

  describe "with another club_file in the same week and season" do
    context "of the same club and player" do
      let(:club_file) { create(:club_file) }
      let(:another_club_file) { build(:club_file, club: club_file.club, player: club_file.player, season_in: club_file.season_in, week_in: club_file.week_in) }
      before { another_club_file.valid? }
      subject { another_club_file }
      it { should_not be_valid }
      it { should have(1).error_on(:player_id) }
      it { another_club_file.error_on(:player_id).should include I18n.t('activerecord.errors.models.club_file.attributes.player_id.only_one_player') }
    end

    context "of the same player in another club" do
      let(:club_file) { create(:club_file) }
      let(:another_club_file) { build(:club_file, player: club_file.player, season_in: club_file.season_in, week_in: club_file.week_in) }
      before { another_club_file.valid? }
      subject { another_club_file }
      it { should_not be_valid }
      it { should have(1).error_on(:player_id) }
      it { another_club_file.error_on(:player_id).should include I18n.t('activerecord.errors.models.club_file.attributes.player_id.only_one_player') }
    end
  end
end
