class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.imageAsset,
    this.imageWidthFactor = 1,
    this.imageHeightFactor = 1,
  });

  final String title;
  final String description;
  final String imageAsset;
  final double imageWidthFactor;
  final double imageHeightFactor;
}
