part of 'onboarding_bloc.dart';

sealed class OnboardingEvent {}

/// User tapped Next or Get Started
class OnboardingNextTapped extends OnboardingEvent {}

/// PageView swiped manually
class OnboardingPageChanged extends OnboardingEvent {
  final int index;
  OnboardingPageChanged(this.index);
}
