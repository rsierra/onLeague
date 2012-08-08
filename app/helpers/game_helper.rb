module GameHelper
  def goal_text(goal)
    case goal.kind
    when 'regular'
      text = goal.scorer.name
      text += " " + t('.assistant', name: goal.assistant.name) unless goal.assistant.blank?
      text
    when 'own' then t('.own', name: goal.scorer.name)
    when 'penalty' then t('.penalty', name: goal.scorer.name)
    when 'penalty_saved' then t('.penalty_saved', name: goal.scorer.name)
    when 'penalty_out' then t('.penalty_out', name: goal.scorer.name)
    end
  end

  def home_event event
    if event.instance_of? Substitution
      home_substitution event
    elsif event.instance_of? Card
      home_card event
    elsif event.instance_of? Goal
      home_goal event
    end
  end

  def home_substitution substitution
    home_event_row  t('.substitution', in: substitution.player_in.name, out: substitution.player_out.name),
                    substitution.minute,
                    'substitution'
  end

  def home_card card
    home_event_row card.player.name, card.minute, "#{card.kind.gsub('_','-')}-card"
  end

  def home_goal goal
    home_event_row goal_text(goal), goal.minute, 'goal'
  end

  def away_event event
    if event.instance_of? Substitution
      away_substitution event
    elsif event.instance_of? Card
      away_card event
    elsif event.instance_of? Goal
      away_goal event
    end
  end

  def away_substitution substitution
    away_event_row  t('.substitution', in: substitution.player_in.name, out: substitution.player_out.name),
                    substitution.minute,
                    'substitution'
  end

  def away_card card
    away_event_row card.player.name, card.minute, "#{card.kind.gsub('_','-')}-card"
  end

  def away_goal goal
    away_event_row goal_text(goal), goal.minute, 'goal'
  end

  def home_event_row(text, minute, icon)
    content_tag :tr do
      content_tag(:td, text, class: 'column-home') +
      content_tag(:td, class: 'column-icon') do
        content_tag(:span, nil, class: "icon #{icon}")
      end +
      content_tag(:td, "#{minute}'", class: 'column-minute') +
      content_tag(:td, nil, class: 'column-icon') +
      content_tag(:td, nil, class: 'column-away')
    end
  end

  def away_event_row(text, minute, icon)
    content_tag :tr do
      content_tag(:td, nil, class: 'column-home') +
      content_tag(:td, nil, class: 'column-icon') +
      content_tag(:td, "#{minute}'", class: 'column-minute') +
      content_tag(:td, class: 'column-icon') do
        content_tag(:span, nil, class: "icon #{icon}")
      end +
      content_tag(:td, text, class: 'column-away')
    end
  end
end
