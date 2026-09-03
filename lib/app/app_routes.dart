import 'package:flutter/material.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/verification_page.dart';
import '../features/buyer_products/presentation/pages/buyer_products_page.dart';
import '../features/buyer_products/presentation/pages/buyer_product_detail_page.dart';
import '../features/buyer_products/presentation/pages/buyer_empty_search_page.dart';
import '../features/buyer_products/presentation/pages/pre_reservation_page.dart';
import '../features/buyer_products/presentation/pages/product_reservation_page.dart';
import '../features/buyer_products/presentation/pages/buyer_payment_page.dart';
import '../features/buyer_products/presentation/pages/buyer_reservation_confirmation_page.dart';
import '../features/buyer_purchases/presentation/pages/buyer_purchases_page.dart';
import '../features/buyer_purchases/presentation/pages/buyer_order_tracking_page.dart';
import '../features/buyer_needs/presentation/pages/publish_buyer_need_page.dart';
import '../features/buyer_needs/presentation/pages/buyer_needs_page.dart';
import '../features/buyer_favorites/presentation/pages/buyer_favorites_page.dart';
import '../features/buyer_favorites/presentation/pages/buyer_create_alert_page.dart';
import '../features/buyer_profile/presentation/pages/buyer_profile_page.dart';
import '../features/buyer_profile/presentation/pages/buyer_account_pages.dart';
import '../features/buyer_profile/presentation/pages/buyer_delivery_addresses_page.dart';
import '../features/buyer_profile/presentation/pages/buyer_address_form_page.dart';
import '../features/buyer_payments/presentation/pages/buyer_payment_history_page.dart';
import '../features/buyer_payments/presentation/pages/buyer_payment_detail_page.dart';
import '../features/buyer_payments/presentation/pages/buyer_saved_payment_methods_page.dart';
import '../features/buyer_favorites/presentation/pages/buyer_alert_detail_page.dart';
import '../features/buyer_support/presentation/pages/buyer_issue_detail_page.dart';
import '../features/buyer_support/presentation/pages/buyer_action_success_page.dart';
import '../features/buyer_needs/presentation/pages/buyer_proposal_checkout_pages.dart';
import '../features/buyer_notifications/presentation/pages/buyer_notifications_page.dart';
import '../features/buyer_support/presentation/pages/buyer_report_problem_page.dart';
import '../features/buyer_needs/presentation/pages/buyer_need_detail_page.dart';
import '../features/buyer_reviews/presentation/pages/buyer_rate_transaction_page.dart';
import '../features/buyer_needs/presentation/pages/buyer_proposals_page.dart';
import '../features/buyer_needs/presentation/pages/buyer_proposal_detail_page.dart';
import '../features/farmer_services/presentation/pages/farmer_services_pages.dart';
import '../features/farmer_services/presentation/pages/farmer_marketplace_pages.dart';
import '../features/harvest_publication/presentation/pages/harvest_publication_page.dart';
import '../features/harvest_detail/presentation/pages/harvest_detail_page.dart';
import '../features/harvest_edit/presentation/pages/harvest_edit_page.dart';
import '../features/harvest_boost/presentation/pages/harvest_boost_page.dart';
import '../features/harvests/presentation/pages/farmer_harvests_page.dart';
import '../features/home/presentation/pages/profile_home_page.dart';
import '../features/profile_selection/presentation/pages/profile_selection_page.dart';
import '../features/profile/presentation/pages/farmer_profile_page.dart';
import '../features/reservations/presentation/pages/reservations_received_page.dart';
import '../features/reservations/presentation/pages/reservation_detail_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/stock_management/presentation/pages/stock_management_page.dart';
import '../features/reviews/presentation/pages/reviews_reputation_page.dart';

abstract final class AppRoutes {
  static const String splash = SplashPage.routeName;
  static const String login = LoginPage.routeName;
  static const String verification = VerificationPage.routeName;
  static const String profileSelection = ProfileSelectionPage.routeName;
  static const String home = ProfileHomePage.routeName;
  static const String publishHarvest = HarvestPublicationPage.routeName;
  static const String harvestDetail = HarvestDetailPage.routeName;
  static const String harvestEdit = HarvestEditPage.routeName;
  static const String harvestBoost = HarvestBoostPage.routeName;
  static const String farmerHarvests = FarmerHarvestsPage.routeName;
  static const String reservationsReceived = ReservationsReceivedPage.routeName;
  static const String reservationDetail = ReservationDetailPage.routeName;
  static const String stockManagement = StockManagementPage.routeName;
  static const String farmerProfile = FarmerProfilePage.routeName;
  static const String reviewsReputation = ReviewsReputationPage.routeName;
  static const String paymentsWithdrawals = PaymentsWithdrawalsPage.routeName;
  static const String myNeeds = MyNeedsPage.routeName;
  static const String wantedProducts = WantedProductsPage.routeName;
  static const String opportunities = OpportunitiesPage.routeName;
  static const String farmerProductResponse =
      FarmerProductResponsePage.routeName;
  static const String seedSearch = SeedSearchPage.routeName;
  static const String farm = FarmPage.routeName;
  static const String settings = SettingsPage.routeName;
  static const String helpSupport = HelpSupportPage.routeName;
  static const String notifications = NotificationsPage.routeName;
  static const String buyerProducts = BuyerProductsPage.routeName;
  static const String buyerProductDetail = BuyerProductDetailPage.routeName;
  static const String buyerEmptySearch = BuyerEmptySearchPage.routeName;
  static const String preReservation = PreReservationPage.routeName;
  static const String productReservation = ProductReservationPage.routeName;
  static const String buyerPayment = BuyerPaymentPage.routeName;
  static const String buyerReservationConfirmation =
      BuyerReservationConfirmationPage.routeName;
  static const String buyerPurchases = BuyerPurchasesPage.routeName;
  static const String buyerOrderTracking = BuyerOrderTrackingPage.routeName;
  static const String publishBuyerNeed = PublishBuyerNeedPage.routeName;
  static const String buyerNeeds = BuyerNeedsPage.routeName;
  static const String buyerFavorites = BuyerFavoritesPage.routeName;
  static const String buyerCreateAlert = BuyerCreateAlertPage.routeName;
  static const String buyerProfile = BuyerProfilePage.routeName;
  static const String buyerDeliveryAddresses =
      BuyerDeliveryAddressesPage.routeName;
  static const String buyerAddressForm = BuyerAddressFormPage.routeName;
  static const String buyerPaymentHistory = BuyerPaymentHistoryPage.routeName;
  static const String buyerPaymentDetail = BuyerPaymentDetailPage.routeName;
  static const String buyerNeedDetail = BuyerNeedDetailPage.routeName;
  static const String buyerRateTransaction = BuyerRateTransactionPage.routeName;
  static const String buyerProposals = BuyerProposalsPage.routeName;
  static const String buyerProposalDetail = BuyerProposalDetailPage.routeName;
  static const String buyerNotifications = BuyerNotificationsPage.routeName;
  static const String buyerReportProblem = BuyerReportProblemPage.routeName;
  static const String buyerPersonalInfo = BuyerPersonalInfoPage.routeName;
  static const String buyerSettings = BuyerSettingsPage.routeName;
  static const String buyerHelpSupport = BuyerHelpSupportPage.routeName;
  static const String buyerReputation = BuyerReputationPage.routeName;
  static const String buyerAlertDetail = BuyerAlertDetailPage.routeName;
  static const String buyerIssueDetail = BuyerIssueDetailPage.routeName;
  static const String buyerProposalAccepted =
      BuyerProposalAcceptedPage.routeName;
  static const String buyerProposalPayment = BuyerProposalPaymentPage.routeName;
  static const String buyerActionSuccess = BuyerActionSuccessPage.routeName;
  static const String buyerSavedPaymentMethods =
      BuyerSavedPaymentMethodsPage.routeName;

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (_) => const SplashPage(),
      login: (_) => const LoginPage(),
      verification: VerificationPage.fromRoute,
      profileSelection: (_) => const ProfileSelectionPage(),
      home: ProfileHomePage.fromRoute,
      publishHarvest: (_) => const HarvestPublicationPage(),
      harvestDetail: (_) => const HarvestDetailPage(),
      harvestEdit: HarvestEditPage.fromRoute,
      harvestBoost: HarvestBoostPage.fromRoute,
      farmerHarvests: (_) => const FarmerHarvestsPage(),
      reservationsReceived: (_) => const ReservationsReceivedPage(),
      reservationDetail: ReservationDetailPage.fromRoute,
      stockManagement: StockManagementPage.fromRoute,
      farmerProfile: (_) => const FarmerProfilePage(),
      reviewsReputation: (_) => const ReviewsReputationPage(),
      paymentsWithdrawals: (_) => const PaymentsWithdrawalsPage(),
      myNeeds: (_) => const MyNeedsPage(),
      wantedProducts: (_) => const WantedProductsPage(),
      opportunities: (_) => const OpportunitiesPage(),
      farmerProductResponse: FarmerProductResponsePage.fromRoute,
      seedSearch: (_) => const SeedSearchPage(),
      farm: (_) => const FarmPage(),
      settings: (_) => const SettingsPage(),
      helpSupport: (_) => const HelpSupportPage(),
      notifications: (_) => const NotificationsPage(),
      buyerProducts: (_) => const BuyerProductsPage(),
      buyerProductDetail: BuyerProductDetailPage.fromRoute,
      buyerEmptySearch: BuyerEmptySearchPage.fromRoute,
      preReservation: PreReservationPage.fromRoute,
      productReservation: ProductReservationPage.fromRoute,
      buyerPayment: BuyerPaymentPage.fromRoute,
      buyerReservationConfirmation: BuyerReservationConfirmationPage.fromRoute,
      buyerPurchases: BuyerPurchasesPage.fromRoute,
      buyerOrderTracking: BuyerOrderTrackingPage.fromRoute,
      publishBuyerNeed: PublishBuyerNeedPage.fromRoute,
      buyerNeeds: (_) => const BuyerNeedsPage(),
      buyerFavorites: (_) => const BuyerFavoritesPage(),
      buyerCreateAlert: BuyerCreateAlertPage.fromRoute,
      buyerProfile: (_) => const BuyerProfilePage(),
      buyerDeliveryAddresses: (_) => const BuyerDeliveryAddressesPage(),
      buyerAddressForm: BuyerAddressFormPage.fromRoute,
      buyerPaymentHistory: (_) => const BuyerPaymentHistoryPage(),
      buyerPaymentDetail: BuyerPaymentDetailPage.fromRoute,
      buyerNeedDetail: BuyerNeedDetailPage.fromRoute,
      buyerRateTransaction: BuyerRateTransactionPage.fromRoute,
      buyerProposals: BuyerProposalsPage.fromRoute,
      buyerProposalDetail: BuyerProposalDetailPage.fromRoute,
      buyerNotifications: (_) => const BuyerNotificationsPage(),
      buyerReportProblem: BuyerReportProblemPage.fromRoute,
      buyerPersonalInfo: (_) => const BuyerPersonalInfoPage(),
      buyerSettings: (_) => const BuyerSettingsPage(),
      buyerHelpSupport: (_) => const BuyerHelpSupportPage(),
      buyerReputation: (_) => const BuyerReputationPage(),
      buyerAlertDetail: (_) => const BuyerAlertDetailPage(),
      buyerIssueDetail: BuyerIssueDetailPage.fromRoute,
      buyerProposalAccepted: BuyerProposalAcceptedPage.fromRoute,
      buyerProposalPayment: BuyerProposalPaymentPage.fromRoute,
      buyerActionSuccess: BuyerActionSuccessPage.fromRoute,
      buyerSavedPaymentMethods: (_) => const BuyerSavedPaymentMethodsPage(),
    };
  }
}
