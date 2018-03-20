require 'associatable'

describe 'AssocOptions' do
  describe 'BelongsToOptions' do
    it 'provides defaults' do
      options = BelongsToOptions.new('team')

      expect(options.foreign_key).to eq(:team_id)
      expect(options.class_name).to eq('Team')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = BelongsToOptions.new('contestant',
                                     foreign_key: :contestant_id,
                                     class_name: 'Contestant',
                                     primary_key: :contestant_id
      )

      expect(options.foreign_key).to eq(:contestant_id)
      expect(options.class_name).to eq('Contestant')
      expect(options.primary_key).to eq(:contestant_id)
    end
  end

  describe 'HasManyOptions' do
    it 'provides defaults' do
      options = HasManyOptions.new('obstacles', 'Contestant')

      expect(options.foreign_key).to eq(:contestant_id)
      expect(options.class_name).to eq('Obstacle')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = HasManyOptions.new('obstacles', 'Contestant',
                                   foreign_key: :contestant_id,
                                   class_name: 'Champion',
                                   primary_key: :contestant_id
      )

      expect(options.foreign_key).to eq(:contestant_id)
      expect(options.class_name).to eq('Champion')
      expect(options.primary_key).to eq(:contestant_id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Obstacle < SQLObject
        self.finalize!
      end

      class Contestant < SQLObject
        self.table_name = 'contestants'

        self.finalize!
      end
    end

    it '#model_class returns class of associated object' do
      options = BelongsToOptions.new('contestant')
      expect(options.model_class).to eq(Contestant)

      options = HasManyOptions.new('obstacles', 'Contestant')
      expect(options.model_class).to eq(Obstacle)
    end

    it '#table_name returns table name of associated object' do
      options = BelongsToOptions.new('contestant')
      expect(options.table_name).to eq('contestants')

      options = HasManyOptions.new('contestants', 'Contestant')
      expect(options.table_name).to eq('contestants')
    end
  end
end

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Obstacle < SQLObject
      belongs_to :contestant, foreign_key: :contestant_id

      finalize!
    end

    class Contestant < SQLObject
      self.table_name = 'contestants'

      has_many :obstacles, foreign_key: :contestant_id
      belongs_to :team

      finalize!
    end

    class Team < SQLObject
      has_many :contestants

      finalize!
    end
  end

  describe '#belongs_to' do
    let(:breakfast) { Obstacle.find(1) }
    let(:devon) { Contestant.find(1) }

    it 'fetches `contestant` from `Obstacle` correctly' do
      expect(breakfast).to respond_to(:contestant)
      contestant = breakfast.contestant

      expect(contestant).to be_instance_of(Contestant)
      expect(contestant.fname).to eq('Devon')
    end

    it 'fetches `team` from `Contestant` correctly' do
      expect(devon).to respond_to(:team)
      team = devon.team

      expect(team).to be_instance_of(Team)
      expect(team.address).to eq('26th and Guerrero')
    end

    it 'returns nil if no associated object' do
      stray_cat = Obstacle.find(5)
      expect(stray_cat.contestant).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:ned) { Contestant.find(3) }
    let(:ned_team) { Team.find(2) }

    it 'fetches `obstacles` from `Contestant`' do
      expect(ned).to respond_to(:obstacles)
      obstacles = ned.obstacles

      expect(obstacles.length).to eq(2)

      expected_cat_names = %w(Haskell Markov)
      2.times do |i|
        cat = obstacles[i]

        expect(cat).to be_instance_of(Obstacle)
        expect(cat.name).to eq(expected_cat_names[i])
      end
    end

    it 'fetches `contestants` from `Team`' do
      expect(ned_team).to respond_to(:contestants)
      contestants = ned_team.contestants

      expect(contestants.length).to eq(1)
      expect(contestants[0]).to be_instance_of(Contestant)
      expect(contestants[0].fname).to eq('Ned')
    end

    it 'returns an empty array if no associated items' do
      catless_contestant = Contestant.find(4)
      expect(catless_contestant.obstacles).to eq([])
    end
  end
end
