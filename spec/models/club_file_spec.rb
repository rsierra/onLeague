require 'spec_helper'

describe ClubFile do
  describe "when create" do
    context "with correct data" do
      let(:club_file) { create(:club_file) }
      subject { club_file }

      it { should be_valid }
    end

    context "with data out" do
      let(:club_file) { build(:club_file, date_out: Date.tomorrow) }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:date_out) }
      it { club_file.error_on(:date_out).should include I18n.t('activerecord.errors.models.club_file.attributes.date_out.should_be_blank_in_creation') }
    end

    context "without club" do
      let(:club_file) { build(:club_file, club: nil) }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:club_id) }
      it { club_file.error_on(:club_id).should include I18n.t('errors.messages.blank') }
    end

    context "without player" do
      let(:club_file) { build(:club_file, player: nil) }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:player_id) }
      it { club_file.error_on(:player_id).should include I18n.t('errors.messages.blank') }
    end

    context "without number" do
      let(:club_file) { build(:club_file, number: nil) }
      subject { club_file }

      it { should_not be_valid }
      it { should have(2).error_on(:number) }
      it { club_file.error_on(:number).should include I18n.t('errors.messages.blank') }
      it { club_file.error_on(:number).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with wrong number" do
      let(:club_file) { build(:club_file, number: 'a') }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:number) }
      it { club_file.error_on(:number).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with number equal or greater than 0" do
      let(:club_file) { build(:club_file, number: -1) }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:number) }
      it { club_file.error_on(:number).should include I18n.t('errors.messages.greater_than_or_equal_to', count: 0) }
    end

    context "with number less than 100" do
      let(:club_file) { build(:club_file, number: 100) }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:number) }
      it { club_file.error_on(:number).should include I18n.t('errors.messages.less_than', count: 100) }
    end

    context "without position" do
      let(:club_file) { build(:club_file, position: nil) }
      subject { club_file }

      it { should_not be_valid }
      it { should have(2).error_on(:position) }
      it { club_file.error_on(:position).should include I18n.t('errors.messages.blank') }
      it { club_file.error_on(:position).should include I18n.t('errors.messages.inclusion') }
    end

    context "without value" do
      let(:club_file) { build(:club_file, value: nil) }
      subject { club_file }

      it { should_not be_valid }
      it { should have(2).error_on(:value) }
      it { club_file.error_on(:value).should include I18n.t('errors.messages.blank') }
      it { club_file.error_on(:value).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with wrong value" do
      let(:club_file) { build(:club_file, value: 'a') }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:value) }
      it { club_file.error_on(:value).should include I18n.t('errors.messages.not_a_number') }
    end

    context "without date in" do
      let(:club_file) { build(:club_file, date_in: nil) }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:date_in) }
      it { club_file.error_on(:date_in).should include I18n.t('errors.messages.blank') }
    end

    context "with date out before date in" do
      let(:club_file) { create(:club_file, date_in: Date.today) }
      before { club_file.date_out = Date.yesterday }
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:date_out) }
      it { club_file.error_on(:date_out).should include I18n.t('activerecord.errors.models.club_file.attributes.date_out.should_be_after_in') }
    end

  end

  describe "with another club_file" do
    context "of the same player without date_out" do
      let(:club_file) { create(:club_file) }
      let(:another_club_file) { build(:club_file, player: club_file.player) }
      subject { another_club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:player_id) }
      it { another_club_file.error_on(:player_id).should include I18n.t('activerecord.errors.models.club_file.attributes.player_id.only_one_curent_file_player') }
    end

    context "of the same player with date_out after date in" do
      let(:club_file) { create(:club_file) }
      let(:another_club_file) { build(:club_file, player: club_file.player) }
      subject { another_club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:player_id) }
      it { another_club_file.error_on(:player_id).should include I18n.t('activerecord.errors.models.club_file.attributes.player_id.only_one_curent_file_player') }
    end
  end

  describe "with versioning" do
    context "when create a club file" do
      let(:club_file) { create(:club_file) }
      subject { club_file }

      it { should have(0).versions }
    end

    context "when update a versioned field" do
      let(:club_file) { create(:club_file) }
      before { club_file.value += 1 }
      subject { club_file }

      it { should be_will_create_version }
    end

    context "when update a non versioned field" do
      let(:club_file) { create(:club_file) }
      before { club_file.date_in = club_file.date_in.yesterday }
      subject { club_file }

      it { should_not be_will_create_version }
    end
  end

  describe "with a not current club file" do
    context "when update a versioned field" do
      let(:club_file) { create(:club_file) }
      before do
        club_file.update_attributes(date_out: club_file.date_in.tomorrow)
        club_file.update_attributes(value: club_file.value + 1)
      end
      subject { club_file }

      it { should_not be_valid }
      it { should have(1).error_on(:date_out) }
      it { club_file.error_on(:date_out).should include I18n.t('activerecord.errors.models.club_file.attributes.date_out.prevents_versioning', fields: club_file.i18n_versioned_fields.to_sentence) }
      it { should have(0).versions }
      it { should be_will_create_version }
    end
  end

end
