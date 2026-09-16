import '../../../../core/theme/app_assets.dart';
import 'onboarding_slide.dart';

abstract final class OnboardingSlides {
  static const List<OnboardingSlide> items = [
    OnboardingSlide(
        label: 'Produire et vendre',
        title: 'Faisons grandir\nvotre activité.',
        description:
            'Producteurs, acheteurs et partenaires, réunis autour de l’agriculture.',
        imageAsset: AppAssets.onboardingFarmerLight,
        imageWidthFactor: 1,
        imageHeightFactor: 1),
    OnboardingSlide(
        label: 'Acheter et échanger',
        title: 'Le marché,\nprès de chez vous.',
        description:
            'Trouvez vos produits et échangez directement avec les producteurs.',
        imageAsset: AppAssets.splashScreen2,
        imageWidthFactor: 1,
        imageHeightFactor: 1),
    OnboardingSlide(
        label: 'Accompagner et investir',
        title: 'Des savoir-faire.\nDes projets d’avenir.',
        description:
            'Proposez vos services ou soutenez les projets du monde agricole.',
        imageAsset: AppAssets.splashScreen3,
        imageWidthFactor: 1,
        imageHeightFactor: 1),
  ];
}
