require 'spec_helper'

describe Extensions::PlayerFile do
  let(:error_translation_key) { 'activerecord.errors.models.dummy_model.attributes' }
  let(:only_one_current_error_translation_key) { "#{error_translation_key}.player_id.only_one_curent_file_player" }
  let(:blank_in_creation_error_translation_key) { "#{error_translation_key}.date_out.should_be_blank_in_creation" }
  let(:after_in_error_translation_key) { "#{error_translation_key}.date_out.should_be_after_in" }
  let(:after_last_out_error_translation_key) { "#{error_translation_key}.date_in.should_be_after_last_out" }

  let(:dummy_params) { { player: create(:player), position: 'midfielder', value: 10, date_in: Date.yesterday } }

  before(:all) do
    build_model :dummy_models do
      integer :player_id

      string :position
      float :value
      date :date_in
      date :date_out

      include Extensions::PlayerFile
    end

    I18n.backend.store_translations I18n.locale, activerecord: {
      errors: { models: { dummy_model: { attributes: { player_id: { only_one_curent_file_player: 'Only one error message'} } } } }
    }

    I18n.backend.store_translations I18n.locale, activerecord: {
      errors: { models: { dummy_model: { attributes: { date_out: { should_be_blank_in_creation: 'Blank in creation error message'} } } } }
    }

    I18n.backend.store_translations I18n.locale, activerecord: {
      errors: { models: { dummy_model: { attributes: { date_out: { should_be_after_in: 'After in error message'} } } } }
    }

    I18n.backend.store_translations I18n.locale, activerecord: {
      errors: { models: { dummy_model: { attributes: { date_in: { should_be_after_last_out: 'After last out error message'} } } } }
    }
  end

  describe "when extend a model" do

    context "with correct data" do
      let(:dummy) { DummyModel.new(dummy_params) }
      subject { dummy }

      it { should be_valid }
      it { should respond_to(:player) }
    end

    context "with date out" do
      let(:dummy) { DummyModel.new(dummy_params.merge(date_out: Date.today)) }
      subject { dummy }

      it { should_not be_valid }
      it { should have(1).error_on(:date_out) }
      it { dummy.error_on(:date_out).should include I18n.t(blank_in_creation_error_translation_key) }
    end

    context "without player" do
      let(:dummy) { DummyModel.new(dummy_params.merge(player: nil)) }
      subject { dummy }

      it { should_not be_valid }
      it { should have(1).error_on(:player_id) }
      it { dummy.error_on(:player_id).should include I18n.t('errors.messages.blank') }
    end

    context "without position" do
      let(:dummy) { DummyModel.new(dummy_params.merge(position: nil)) }
      subject { dummy }

      it { should_not be_valid }
      it { should have(2).error_on(:position) }
      it { dummy.error_on(:position).should include I18n.t('errors.messages.blank') }
      it { dummy.error_on(:position).should include I18n.t('errors.messages.inclusion') }
    end

    context "without value" do
      let(:dummy) { DummyModel.new(dummy_params.merge(value: nil)) }
      subject { dummy }

      it { should_not be_valid }
      it { should have(2).error_on(:value) }
      it { dummy.error_on(:value).should include I18n.t('errors.messages.blank') }
      it { dummy.error_on(:value).should include I18n.t('errors.messages.not_a_number') }
    end

    context "with wrong value" do
      let(:dummy) { DummyModel.new(dummy_params.merge(value: 'a')) }
      subject { dummy }

      it { should_not be_valid }
      it { should have(1).error_on(:value) }
      it { dummy.error_on(:value).should include I18n.t('errors.messages.not_a_number') }
    end

    context "without date in" do
      let(:dummy) { DummyModel.new(dummy_params.merge(date_in: nil)) }
      subject { dummy }

      it { should_not be_valid }
      it { should have(1).error_on(:date_in) }
      it { dummy.error_on(:date_in).should include I18n.t('errors.messages.blank') }
    end

    context "with date out before date in" do
      let(:dummy) { DummyModel.create(dummy_params.merge(date_in: Date.today)) }
      before { dummy.date_out = Date.yesterday }
      subject { dummy }

      it { should_not be_valid }
      it { should have(1).error_on(:date_out) }
      it { dummy.error_on(:date_out).should include I18n.t(after_in_error_translation_key) }
    end

    describe "with another club_file" do
      context "of the same player without date_out" do
        let(:dummy) { DummyModel.create(dummy_params) }
        let(:another_dummy) { DummyModel.new(dummy_params.merge(player: dummy.player)) }
        subject { another_dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:player_id) }
        it { another_dummy.error_on(:player_id).should include I18n.t(only_one_current_error_translation_key) }
      end

      context "of the same player with date_out after date in" do
        let(:dummy) { DummyModel.create(dummy_params) }
        let(:another_dummy) { DummyModel.new(dummy_params.merge(player: dummy.player)) }
        subject { another_dummy }

        it { should_not be_valid }
        it { should have(1).error_on(:player_id) }
        it { another_dummy.error_on(:player_id).should include I18n.t(only_one_current_error_translation_key) }
      end
    end
  end

  context "when get current" do
    let(:current_dummy) { DummyModel.create(dummy_params) }
    let(:not_current_dummy) { DummyModel.create(dummy_params) }

    before { current_dummy; not_current_dummy.update_attributes(date_out: Date.today) }

    it { DummyModel.current.should eq [current_dummy] }
  end

  context "when get of a player" do
    let(:dummy) { DummyModel.create(dummy_params) }
    let(:another_dummy) { DummyModel.create(dummy_params.merge(player: create(:player))) }

    before { dummy; another_dummy }

    it { DummyModel.of(dummy.player).should eq [dummy] }
    it { DummyModel.of(another_dummy.player).should eq [another_dummy] }
  end

  context "when get on a date" do
    let(:dummy) { DummyModel.create(dummy_params.merge(date_in: 5.days.ago.to_date)) }
    let(:second_dummy) { DummyModel.create(dummy_params.merge(player: create(:player), date_in: 3.days.ago.to_date)) }
    let(:third_dummy) { DummyModel.create(dummy_params.merge(player: create(:player),date_in: 1.days.ago.to_date)) }

    before do
      dummy
      second_dummy.update_attributes(date_out: 1.days.ago.to_date)
      third_dummy
    end

    it { DummyModel.on(6.days.ago.to_date).should be_empty }
    it { DummyModel.on(5.days.ago.to_date).should eq [dummy] }
    it { DummyModel.on(4.days.ago.to_date).should eq [dummy] }
    it { DummyModel.on(3.days.ago.to_date).should eq [dummy, second_dummy] }
    it { DummyModel.on(2.days.ago.to_date).should eq [dummy, second_dummy] }
    it { DummyModel.on(1.days.ago.to_date).should eq [dummy, second_dummy, third_dummy] }
    it { DummyModel.on(Date.today).should eq [dummy, third_dummy] }
  end

  describe "with #player_last_date_out" do

    context "when have one current club file" do
      let(:player) { create(:player) }
      let(:dummy) { DummyModel.create(dummy_params.merge(player: player)) }
      subject { dummy }

      its(:player_last_date_out) { should eq dummy.date_out }
    end

    context "when have one club file with date out" do
      let(:player) { create(:player) }
      let(:dummy) { DummyModel.create(dummy_params.merge(player: player)) }
      before { dummy.update_attributes(date_out: dummy.date_in.next) }
      subject { dummy }

      its(:player_last_date_out) { should eq dummy.date_out }
    end

    context "when have club file with date out and one current" do
      let(:player) { create(:player) }
      let(:dummy) { DummyModel.create(dummy_params.merge(player: player)) }
      before do
        dummy.update_attributes(date_out: dummy.date_in.next)
        DummyModel.create(dummy_params.merge(player: player, date_in: dummy.date_out.next))
      end
      subject { dummy }

      its(:player_last_date_out) { should eq dummy.date_out }
    end
  end
end
