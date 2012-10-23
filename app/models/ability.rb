class Ability
  include CanCan::Ability

  def initialize(admin)
    alias_action :update, :create, :to => :write

    if admin
      can :access, :rails_admin       # only allow admin users to access Rails Admin
      can :dashboard                  # allow access to dashboard

      can :read, :all                 # allow everyone to read everything
      can :history, :all              # allow everyone to history everything

      can :write, User
      can :write, League
      can :close_week, League
      can :write, Club
      can :write, ClubTranslation
      can :write, Country
      can :write, CountryTranslation
      can :write, Player
      can :write, ClubFile
      can :write, Game
      can :scraper_lineups, Game
      can :scrap_lineups, Game
      can :scraper_substitutions, Game
      can :scrap_substitutions, Game
      can :scraper_cards, Game
      can :scrap_cards, Game
      can :scraper_goals, Game
      can :scrap_goals, Game
      can :update, Goal
      can :destroy, Goal
      can :update, Card
      can :destroy, Card
      can :update, Substitution
      can :destroy, Substitution
      can :update, Lineup
      can :destroy, Lineup
      can :update, GameMark
      can :destroy, GameMark
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
