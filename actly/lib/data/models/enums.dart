enum GoalCategory {
  movement,
  sleep,
  study,
  screenTime,
  hydration,
  social,
  exercise,
}

enum DiagnosisAnswer { yes, somewhat, no }

enum ObstacleType { tired, shortOnTime, badEnvironment, forgot }

enum SkipReason {
  noTime,
  lowEnergy,
  forgot,
  badEnvironment,
  planTooBig,
  consciousChoice,
}

enum ActionTaken { noneYet, full, backup, skip }

enum EntrySource { real, simulation }

enum FeedbackRating { yes, somewhat, no }

enum RecommendationAction { none, editBackup, editTrigger, shrinkPlan }

extension GoalCategoryX on GoalCategory {
  String get label => switch (this) {
        GoalCategory.movement => 'Movement / walking',
        GoalCategory.sleep => 'Sleep routine',
        GoalCategory.study => 'Focused study',
        GoalCategory.screenTime => 'Reduce screen time',
        GoalCategory.hydration => 'Hydration',
        GoalCategory.social => 'Social connection',
        GoalCategory.exercise => 'Exercise',
      };

  String get defaultAction => switch (this) {
        GoalCategory.movement => 'Walk for 20 minutes',
        GoalCategory.sleep => 'Start my wind-down routine at 22:30',
        GoalCategory.study => 'Study without distractions for 30 minutes',
        GoalCategory.screenTime => 'Put my phone away for 30 minutes',
        GoalCategory.hydration => 'Drink one full glass of water',
        GoalCategory.social => 'Call or message someone I care about',
        GoalCategory.exercise => 'Exercise for 25 minutes',
      };

  String get defaultMinimumAction => switch (this) {
        GoalCategory.movement => 'Walk for 5 minutes',
        GoalCategory.sleep => 'Put my phone on charge outside the bed',
        GoalCategory.study => 'Open the material and study for 5 minutes',
        GoalCategory.screenTime => 'Put my phone away for 5 minutes',
        GoalCategory.hydration => 'Take five deliberate sips of water',
        GoalCategory.social => 'Send a 30-second voice message',
        GoalCategory.exercise => 'Change clothes and move for 5 minutes',
      };
}

extension DiagnosisAnswerX on DiagnosisAnswer {
  String get label => switch (this) {
        DiagnosisAnswer.yes => 'Yes',
        DiagnosisAnswer.somewhat => 'Somewhat',
        DiagnosisAnswer.no => 'No',
      };
}

extension ObstacleTypeX on ObstacleType {
  String get label => switch (this) {
        ObstacleType.tired => 'I will probably be tired',
        ObstacleType.shortOnTime => 'I may be short on time',
        ObstacleType.badEnvironment => 'The environment may not cooperate',
        ObstacleType.forgot => 'I may forget',
      };
}

extension SkipReasonX on SkipReason {
  String get label => switch (this) {
        SkipReason.noTime => 'No time',
        SkipReason.lowEnergy => 'Low energy',
        SkipReason.forgot => 'Forgot',
        SkipReason.badEnvironment => 'Bad environment',
        SkipReason.planTooBig => 'Plan was too big',
        SkipReason.consciousChoice => 'Consciously chose not to',
      };

  String get response => switch (this) {
        SkipReason.noTime =>
          'The plan did not fit the available time. A shorter trigger-to-action gap may work better.',
        SkipReason.lowEnergy =>
          'Energy was the constraint. The backup plan should require less activation, not more willpower.',
        SkipReason.forgot =>
          'The trigger was not visible enough. Attach the plan to a moment that is hard to miss.',
        SkipReason.badEnvironment =>
          'The environment blocked the plan. Prepare a version that works in a second location.',
        SkipReason.planTooBig =>
          'The plan was larger than the day allowed. Keep the goal, reduce the first step.',
        SkipReason.consciousChoice =>
          'A conscious skip is still useful data. No adjustment is needed unless this repeats.',
      };
}

extension FeedbackRatingX on FeedbackRating {
  String get label => switch (this) {
        FeedbackRating.yes => 'Yes',
        FeedbackRating.somewhat => 'Somewhat',
        FeedbackRating.no => 'No',
      };
}
