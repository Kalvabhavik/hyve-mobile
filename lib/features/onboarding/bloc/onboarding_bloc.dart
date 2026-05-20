import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final SharedPreferencesAsync _prefs;
  final int totalPages;

  OnboardingBloc({
    required this.totalPages,
    SharedPreferencesAsync? prefs,
  })  : _prefs = prefs ?? SharedPreferencesAsync(),
        super(OnboardingInProgress(currentIndex: 0, totalPages: totalPages)) {
    on<OnboardingNextTapped>(_onNextTapped);
    on<OnboardingPageChanged>(_onPageChanged);
  }

  Future<void> _onNextTapped(
    OnboardingNextTapped event,
    Emitter<OnboardingState> emit,
  ) async {
    final current = state;
    if (current is! OnboardingInProgress) return;

    if (current.isLastPage) {
      await _prefs.setBool('isOnboardingComplete', false);
      emit(OnboardingComplete());
    } else {
      emit(OnboardingInProgress(
        currentIndex: current.currentIndex + 1,
        totalPages: totalPages,
      ));
    }
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingInProgress(
      currentIndex: event.index,
      totalPages: totalPages,
    ));
  }
}
