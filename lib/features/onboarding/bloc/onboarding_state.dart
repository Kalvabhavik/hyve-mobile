part of 'onboarding_bloc.dart';

sealed class OnboardingState {}

/// Normal state — user is viewing a slide
class OnboardingInProgress extends OnboardingState {
  final int currentIndex;
  final int totalPages;

  OnboardingInProgress({
    required this.currentIndex,
    required this.totalPages,
  });

  bool get isLastPage => currentIndex == totalPages - 1;
}

/// Prefs saved, ready to navigate — UI listens and pushes HomePage
class OnboardingComplete extends OnboardingState {}
