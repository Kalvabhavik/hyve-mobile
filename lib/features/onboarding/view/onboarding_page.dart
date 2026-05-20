import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyve/features/home/view/home_page.dart';
import 'package:hyve/features/onboarding/bloc/onboarding_bloc.dart';

// ─── Assets & Colors ────────────────────────────────────────────────────────

class ImagesPath {
  static String kOnboarding1 = 'assets/onboarding/onboarding1.png';
  static String kOnboarding2 = 'assets/onboarding/onBoarding2.png';
  static String kOnboarding3 = 'assets/onboarding/onBoarding3.png';
}

class AppColor {
  static Color kPrimary = const Color(0XFF1460F2);
  static Color kWhite = const Color(0XFFFFFFFF);
  static Color kOnBoardingColor = const Color(0XFFFEFEFE);
  static Color kGrayscale40 = const Color(0XFFAEAEB2);
  static Color kGrayscaleDark100 = const Color(0XFF1C1C1E);
}

// ─── Data Model ─────────────────────────────────────────────────────────────

class OnBoardingModel {
  final String title;
  final String description;
  final String image;

  const OnBoardingModel({
    required this.title,
    required this.description,
    required this.image,
  });
}

const List<OnBoardingModel> onBoardinglist = [
  OnBoardingModel(
    title: 'Your Campus, Unified',
    description:
        'One app to navigate logistics, access services, and thrive — friction-free.',
    image: 'assets/onboarding/onboarding1.png',
  ),
  OnBoardingModel(
    title: 'Stay in the Loop',
    description: 'News, announcements, events, and a vibrant community for all your academic and non-academic needs.',
    image: 'assets/onboarding/onBoarding2.png',
  ),
  OnBoardingModel(
    title: 'Organize Your Day',
    description: 'Timetables, planners, and schedules — all in one place, always at your fingertips.',
    image: 'assets/onboarding/onBoarding3.png',
  ),
];

// ─── Screen (provides its own BLoC) ─────────────────────────────────────────

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(totalPages: onBoardinglist.length),
      child: const _OnBoardingView(),
    );
  }
}

// ─── View (consumes BLoC) ────────────────────────────────────────────────────

class _OnBoardingView extends StatefulWidget {
  const _OnBoardingView();

  @override
  State<_OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<_OnBoardingView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Drive the PageView when BLoC increments the page (Next button tap).
  /// Manual swipes update BLoC via onPageChanged — no need to animate there.
  void _syncPageController(int index) {
    if (_pageController.hasClients &&
        _pageController.page?.round() != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingInProgress) {
          // Keep PageView in sync when Next was tapped
          _syncPageController(state.currentIndex);
        } else if (state is OnboardingComplete) {
          // Navigate — BLoC already saved prefs, nothing else to do here
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        }
      },
      builder: (context, state) {
        // Guard: only build UI while onboarding is in progress
        if (state is! OnboardingInProgress) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: AppColor.kOnBoardingColor,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                height: 10,
                width: 10,
                margin: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.kPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: onBoardinglist.length,
                  onPageChanged: (index) {
                    context
                        .read<OnboardingBloc>()
                        .add(OnboardingPageChanged(index));
                  },
                  itemBuilder: (context, index) {
                    return OnBoardingCard(
                      onBoardingModel: onBoardinglist[index],
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: DotsIndicator(
                  dotsCount: onBoardinglist.length,
                  position: state.currentIndex.toDouble(),
                  decorator: DotsDecorator(
                    color: AppColor.kPrimary.withValues(alpha: 0.4),
                    size: const Size.square(8.0),
                    activeSize: const Size(20.0, 8.0),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    activeColor: AppColor.kPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 23, bottom: 36),
                child: PrimaryButton(
                  elevation: 0,
                  onTap: () =>
                      context.read<OnboardingBloc>().add(OnboardingNextTapped()),
                  text: state.isLastPage ? 'Get Started' : 'Next',
                  bgColor: AppColor.kPrimary,
                  borderRadius: 20,
                  height: 46,
                  width: double.infinity,
                  textColor: AppColor.kWhite,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────────────────────────

class PrimaryButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;
  final double? width;
  final double? height;
  final double? borderRadius, elevation;
  final double? fontSize;
  final IconData? iconData;
  final Color? textColor, bgColor;

  const PrimaryButton({
    super.key,
    required this.onTap,
    required this.text,
    this.width,
    this.height,
    this.elevation = 5,
    this.borderRadius,
    this.fontSize,
    required this.textColor,
    required this.bgColor,
    this.iconData,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Tween<double> _tween = Tween<double>(begin: 1.0, end: 0.80);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _animationDuration)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) => _controller.reverse());
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _tween.animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        ),
        child: Card(
          elevation: widget.elevation ?? 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius!),
          ),
          child: Container(
            height: widget.height ?? 55,
            alignment: Alignment.center,
            width: widget.width ?? double.maxFinite,
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius!),
            ),
            child: Text(
              widget.text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: widget.fontSize ?? 14,
                fontWeight: FontWeight.w500,
                color: widget.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnBoardingCard extends StatelessWidget {
  final OnBoardingModel onBoardingModel;

  const OnBoardingCard({super.key, required this.onBoardingModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: SizedBox()),
        Image.asset(
          onBoardingModel.image,
          height: 300,
          width: double.maxFinite,
          fit: BoxFit.fitWidth,
        ),
        const Expanded(child: SizedBox()),
        OnboardingTextCard(onBoardingModel: onBoardingModel),
      ],
    );
  }
}

class OnboardingTextCard extends StatelessWidget {
  final OnBoardingModel onBoardingModel;

  const OnboardingTextCard({required this.onBoardingModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: Column(
        children: [
          Text(
            onBoardingModel.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.kGrayscaleDark100,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            onBoardingModel.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.kGrayscale40,
            ),
          ),
        ],
      ),
    );
  }
}
