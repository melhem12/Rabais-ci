import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'RABAIS CI'**
  String get appName;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Customer label
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// Role label
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// Balance label
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// Merchant partners page title
  ///
  /// In en, this message translates to:
  /// **'Merchant Partners'**
  String get merchantPartners;

  /// Placeholder for partner search
  ///
  /// In en, this message translates to:
  /// **'Search partners'**
  String get searchPartners;

  /// Message when no partners are found
  ///
  /// In en, this message translates to:
  /// **'No partners found'**
  String get noPartnersFound;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Phone label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Special offers section title
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get specialOffers;

  /// Discover exclusive offers text
  ///
  /// In en, this message translates to:
  /// **'Discover Exclusive Offers'**
  String get discoverExclusive;

  /// Purchases feature name
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// Message when no purchases are found
  ///
  /// In en, this message translates to:
  /// **'No purchases found'**
  String get noPurchasesFound;

  /// Purchase details title
  ///
  /// In en, this message translates to:
  /// **'Purchase Details'**
  String get purchaseDetails;

  /// QR code label
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// Instruction to show QR code to merchant
  ///
  /// In en, this message translates to:
  /// **'Show this QR code to the merchant to use your voucher'**
  String get showQrToMerchant;

  /// Purchase date label
  ///
  /// In en, this message translates to:
  /// **'Purchased on'**
  String get purchasedOn;

  /// Expiration date label
  ///
  /// In en, this message translates to:
  /// **'Expires on'**
  String get expiresOn;

  /// Active status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Used status
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// Expired status
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Voucher label
  ///
  /// In en, this message translates to:
  /// **'Voucher'**
  String get voucher;

  /// Code label
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// Available features title
  ///
  /// In en, this message translates to:
  /// **'Available Features'**
  String get availableFeatures;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Phone number input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// OTP request explanation
  ///
  /// In en, this message translates to:
  /// **'We will send you a verification code'**
  String get weWillSendCode;

  /// OTP request button text
  ///
  /// In en, this message translates to:
  /// **'Receive OTP Code'**
  String get receiveOtpCode;

  /// OTP verification page title
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// OTP verification page subtitle
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verifyYourNumber;

  /// OTP sent confirmation
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to'**
  String get weSentCodeTo;

  /// OTP input instruction
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code'**
  String get enterFourDigitCode;

  /// Verify button text
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Resend OTP button text
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// Profile completion page title
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get profileCompletion;

  /// Profile completion instruction
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to continue'**
  String get completeYourProfile;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field label with optional indicator
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// Date of birth field label
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// Date of birth field label with optional indicator
  ///
  /// In en, this message translates to:
  /// **'Date of birth (optional)'**
  String get dateOfBirthOptional;

  /// Gender field label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Gender field label with optional indicator
  ///
  /// In en, this message translates to:
  /// **'Gender (optional)'**
  String get genderOptional;

  /// Section title for profile information
  ///
  /// In en, this message translates to:
  /// **'Profile information'**
  String get profileInformation;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Non-binary gender option
  ///
  /// In en, this message translates to:
  /// **'Non-binary'**
  String get nonBinary;

  /// Other gender option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Unknown gender option
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get unknown;

  /// Complete profile button text
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// First name validation message
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// Last name validation message
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// Invalid email validation message
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// Action to clear an input field
  ///
  /// In en, this message translates to:
  /// **'Clear field'**
  String get clearField;

  /// Label for additional info section
  ///
  /// In en, this message translates to:
  /// **'Additional info (optional)'**
  String get additionalInfoOptional;

  /// Helper text for additional info section
  ///
  /// In en, this message translates to:
  /// **'Add any extra profile details as key/value pairs.'**
  String get additionalInfoHint;

  /// Label for additional info key field
  ///
  /// In en, this message translates to:
  /// **'Field name'**
  String get additionalInfoKeyLabel;

  /// Label for additional info value field
  ///
  /// In en, this message translates to:
  /// **'Field value'**
  String get additionalInfoValueLabel;

  /// Button label to add another additional info field
  ///
  /// In en, this message translates to:
  /// **'Add info field'**
  String get addAdditionalInfoField;

  /// Tooltip to remove an additional info field
  ///
  /// In en, this message translates to:
  /// **'Remove field'**
  String get removeAdditionalInfoField;

  /// Button label to save profile changes
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// Success message when the profile is updated
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// Help text for profile completion
  ///
  /// In en, this message translates to:
  /// **'This information will help us personalize your experience'**
  String get helpPersonalizeExperience;

  /// Customer home page title
  ///
  /// In en, this message translates to:
  /// **'Customer Home'**
  String get customerHome;

  /// Merchant home page title
  ///
  /// In en, this message translates to:
  /// **'Merchant Console'**
  String get merchantConsole;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// Wallet feature name
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// Vouchers feature name
  ///
  /// In en, this message translates to:
  /// **'Vouchers'**
  String get vouchers;

  /// Profile feature name
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// QR scanner feature name
  ///
  /// In en, this message translates to:
  /// **'QR Scanner'**
  String get qrScanner;

  /// Manual entry tab title
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// History feature name
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Wallet page title
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletPage;

  /// Current balance label
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// Coins currency
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Top up action
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// Transaction history action
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// Recent transactions section title
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// Empty transactions message
  ///
  /// In en, this message translates to:
  /// **'No recent transactions'**
  String get noRecentTransactions;

  /// Credit transaction type
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// Debit transaction type
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get debit;

  /// Vouchers page title
  ///
  /// In en, this message translates to:
  /// **'Discount Vouchers'**
  String get vouchersPage;

  /// Voucher search hint
  ///
  /// In en, this message translates to:
  /// **'Search vouchers...'**
  String get searchVouchers;

  /// All category filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Restaurants category
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// Shopping category
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// Services category
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// Heading for business type filters
  ///
  /// In en, this message translates to:
  /// **'Business types'**
  String get businessFiltersTitle;

  /// Error message when business filters fail to load
  ///
  /// In en, this message translates to:
  /// **'Unable to load filters'**
  String get businessFiltersLoadError;

  /// Minimum price filter label
  ///
  /// In en, this message translates to:
  /// **'Min price (in cents)'**
  String get minPrice;

  /// Maximum price filter label
  ///
  /// In en, this message translates to:
  /// **'Max price (in cents)'**
  String get maxPrice;

  /// Expires before filter label
  ///
  /// In en, this message translates to:
  /// **'Expires before'**
  String get expiresBefore;

  /// Prompt to select a date
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// Button to clear all filters
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// Empty vouchers message
  ///
  /// In en, this message translates to:
  /// **'No vouchers found'**
  String get noVouchersFound;

  /// Buy voucher button
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// Claim free voucher button
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get claim;

  /// Confirmation message for claiming a free coupon
  ///
  /// In en, this message translates to:
  /// **'Do you want to accept your free coupon?'**
  String get confirmClaimFree;

  /// Voucher validity label
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get validUntil;

  /// Voucher details page title
  ///
  /// In en, this message translates to:
  /// **'Voucher Details'**
  String get voucherDetails;

  /// Validity section title
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get validity;

  /// From date label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// To date label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// Available quantity label
  ///
  /// In en, this message translates to:
  /// **'Available quantity'**
  String get availableQuantity;

  /// Buy now button
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// Purchase confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get confirmPurchase;

  /// Purchase confirmation message
  ///
  /// In en, this message translates to:
  /// **'Do you want to buy \"{voucherTitle}\" for {price} {currency}?'**
  String confirmPurchaseMessage(
    String voucherTitle,
    String price,
    String currency,
  );

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Redemption page title
  ///
  /// In en, this message translates to:
  /// **'Redemption'**
  String get redemption;

  /// Scan QR tab title
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQr;

  /// QR scanner instruction
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// QR scanner instruction text
  ///
  /// In en, this message translates to:
  /// **'Place the QR code in the frame to scan it'**
  String get placeQrInFrame;

  /// Scan button text
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// Manual entry page title
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntryTitle;

  /// Manual entry instruction
  ///
  /// In en, this message translates to:
  /// **'Enter the redemption code manually'**
  String get enterRedemptionCode;

  /// Redemption code field label
  ///
  /// In en, this message translates to:
  /// **'Redemption Code'**
  String get redemptionCode;

  /// Redemption code field hint
  ///
  /// In en, this message translates to:
  /// **'Ex: ABCD1234'**
  String get redemptionCodeHint;

  /// Redeem button text
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// Redemption history page title
  ///
  /// In en, this message translates to:
  /// **'Redemption History'**
  String get redemptionHistory;

  /// Empty redemptions message
  ///
  /// In en, this message translates to:
  /// **'No redemptions found'**
  String get noRedemptionsFound;

  /// Method label
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Filters section title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Date range label
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// Prompt to select a date range
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get selectDateRange;

  /// Displayed when no date range is selected
  ///
  /// In en, this message translates to:
  /// **'No date selected'**
  String get noDateSelected;

  /// Dropdown label for page size
  ///
  /// In en, this message translates to:
  /// **'Items per page'**
  String get limit;

  /// Business selection label
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// Completed redemption status label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get redemptionStatusCompleted;

  /// Pending redemption status label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get redemptionStatusPending;

  /// Failed redemption status label
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get redemptionStatusFailed;

  /// QR code redemption method label
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get redemptionMethodQrCode;

  /// Manual code redemption method label
  ///
  /// In en, this message translates to:
  /// **'Manual code'**
  String get redemptionMethodManualCode;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Success status
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Failed status
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Personal info setting
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// Personal info description
  ///
  /// In en, this message translates to:
  /// **'Modify your information'**
  String get modifyYourInfo;

  /// Security setting
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Security description
  ///
  /// In en, this message translates to:
  /// **'Password and authentication'**
  String get passwordAndAuth;

  /// Application settings section
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get application;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Notifications setting
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notifications description
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get manageNotifications;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Support section
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Help setting
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Help description
  ///
  /// In en, this message translates to:
  /// **'FAQ and support'**
  String get faqAndSupport;

  /// Contact us setting
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Contact us description
  ///
  /// In en, this message translates to:
  /// **'Customer support'**
  String get customerSupport;

  /// About setting
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App version
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// Account section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Logout dialog title
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmation;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmationMessage;

  /// Notifications page title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsPage;

  /// Notification types section
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// Push notifications setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Push notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive notifications on your device'**
  String get receiveDeviceNotifications;

  /// Email notifications setting
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// Email notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive notifications by email'**
  String get receiveEmailNotifications;

  /// SMS notifications setting
  ///
  /// In en, this message translates to:
  /// **'SMS Notifications'**
  String get smsNotifications;

  /// SMS notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive notifications by SMS'**
  String get receiveSmsNotifications;

  /// Categories section
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Promotional notifications setting
  ///
  /// In en, this message translates to:
  /// **'Promotional Notifications'**
  String get promotionalNotifications;

  /// Promotional notifications description
  ///
  /// In en, this message translates to:
  /// **'New vouchers and special offers'**
  String get newVouchersAndOffers;

  /// Transaction notifications setting
  ///
  /// In en, this message translates to:
  /// **'Transaction Notifications'**
  String get transactionNotifications;

  /// Transaction notifications description
  ///
  /// In en, this message translates to:
  /// **'Purchase and redemption confirmations'**
  String get purchaseAndRedemptionConfirmations;

  /// Security notifications setting
  ///
  /// In en, this message translates to:
  /// **'Security Notifications'**
  String get securityNotifications;

  /// Security notifications description
  ///
  /// In en, this message translates to:
  /// **'Logins and account changes'**
  String get loginAndAccountChanges;

  /// Frequency section
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// Notification frequency setting
  ///
  /// In en, this message translates to:
  /// **'Notification Frequency'**
  String get notificationFrequency;

  /// Immediate frequency option
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get immediately;

  /// Daily frequency option
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Weekly frequency option
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Test section
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// Test notification setting
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get sendTestNotification;

  /// Test notification description
  ///
  /// In en, this message translates to:
  /// **'Test your notification settings'**
  String get testYourNotificationSettings;

  /// Test notification success message
  ///
  /// In en, this message translates to:
  /// **'Test notification sent!'**
  String get testNotificationSent;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// Network error instruction
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get checkInternetConnection;

  /// Access denied message
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// Access denied instruction
  ///
  /// In en, this message translates to:
  /// **'Please reconnect'**
  String get pleaseReconnect;

  /// Service not found message
  ///
  /// In en, this message translates to:
  /// **'Service not found'**
  String get serviceNotFound;

  /// Invalid data message
  ///
  /// In en, this message translates to:
  /// **'Invalid data. Check your information'**
  String get invalidData;

  /// Unknown error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get unknownError;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Coming soon description
  ///
  /// In en, this message translates to:
  /// **'This feature will be available soon'**
  String get featureWillBeAvailableSoon;

  /// Phone number validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// OTP validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete code'**
  String get enterCompleteCode;

  /// Free voucher type
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Paid voucher type
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// Inactive status
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Unavailable status
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// Quantity label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Price label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Coin price label
  ///
  /// In en, this message translates to:
  /// **'Coin Price'**
  String get coinPrice;

  /// Label for price per coin
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get coinUnitPrice;

  /// Title for the coin packages list
  ///
  /// In en, this message translates to:
  /// **'Available coin packages'**
  String get availableCoinPackages;

  /// Empty state message when no packages are returned
  ///
  /// In en, this message translates to:
  /// **'No coin packages available right now.'**
  String get noCoinPackagesAvailable;

  /// Success message after confirming a coin top-up
  ///
  /// In en, this message translates to:
  /// **'Your recharge request was sent successfully.'**
  String get topUpSuccessful;

  /// Badge shown on recently added packages
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// Message shown when a package is inactive
  ///
  /// In en, this message translates to:
  /// **'This package is currently unavailable.'**
  String get packageCurrentlyUnavailable;

  /// Label for card payment option
  ///
  /// In en, this message translates to:
  /// **'Bank card'**
  String get paymentMethodCard;

  /// Label for Wave payment option
  ///
  /// In en, this message translates to:
  /// **'Wave'**
  String get paymentMethodWave;

  /// Label for generic mobile money option
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get paymentMethodMobileMoney;

  /// Label for PaiementPro payment option
  ///
  /// In en, this message translates to:
  /// **'PaiementPro'**
  String get paymentMethodPaiementPro;

  /// Snackbar when opening PaiementPro flow
  ///
  /// In en, this message translates to:
  /// **'Redirecting to PaiementPro…'**
  String get redirectingPaiementPro;

  /// Code validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a code'**
  String get pleaseEnterCode;

  /// Purchase success message
  ///
  /// In en, this message translates to:
  /// **'Purchase successful!'**
  String get purchaseSuccess;

  /// Barcode label
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// Scan barcode button
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// Search voucher button
  ///
  /// In en, this message translates to:
  /// **'Search voucher'**
  String get searchVoucher;

  /// Barcode validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a barcode'**
  String get pleaseEnterBarcode;

  /// Preview voucher button
  ///
  /// In en, this message translates to:
  /// **'Preview Voucher'**
  String get previewVoucher;

  /// Purchase voucher button
  ///
  /// In en, this message translates to:
  /// **'Purchase Voucher'**
  String get purchaseVoucher;

  /// Sponsored banners title
  ///
  /// In en, this message translates to:
  /// **'Sponsored Banners'**
  String get sponsoredBanners;

  /// QR scanner placeholder message
  ///
  /// In en, this message translates to:
  /// **'Camera scanner will be available soon'**
  String get qrScannerPlaceholder;

  /// Merchant console page title
  ///
  /// In en, this message translates to:
  /// **'Merchant Console'**
  String get merchantConsoleTitle;

  /// Redemption code validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a redemption code'**
  String get pleaseEnterRedemptionCode;

  /// QR scanner coming soon message
  ///
  /// In en, this message translates to:
  /// **'QR Scanner will be available soon'**
  String get qrScannerComingSoon;

  /// Empty transactions message
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// Discount label
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// Redemption tools section title
  ///
  /// In en, this message translates to:
  /// **'Redemption Tools'**
  String get toolsForRedemption;

  /// Redemption tools title
  ///
  /// In en, this message translates to:
  /// **'Redemption Tools'**
  String get redemptionTools;

  /// Business information section title
  ///
  /// In en, this message translates to:
  /// **'Business Information'**
  String get businessInformation;

  /// Payment method selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Payment Method'**
  String get choosePaymentMethod;

  /// Wallet payment method
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletPayment;

  /// Coins payment method
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coinsPayment;

  /// Mixed payment method
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixedPayment;

  /// Wallet and coins combined payment
  ///
  /// In en, this message translates to:
  /// **'Wallet + Coins'**
  String get walletAndCoins;

  /// Insufficient balance warning message
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance. Please top up your wallet.'**
  String get insufficientBalance;

  /// Purchase confirmation question
  ///
  /// In en, this message translates to:
  /// **'Do you want to buy \"{voucherTitle}\"?'**
  String wantToBuyVoucher(String voucherTitle);

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Or connector word
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Active vouchers count label
  ///
  /// In en, this message translates to:
  /// **'Active Vouchers'**
  String get activeVouchers;

  /// Camera permission required message
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan QR codes'**
  String get cameraPermissionRequired;

  /// Camera permission denied message
  ///
  /// In en, this message translates to:
  /// **'Camera permission is permanently denied. Please enable it in settings.'**
  String get cameraPermissionDenied;

  /// Open settings button text
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Message shown when the OTP is sent successfully
  ///
  /// In en, this message translates to:
  /// **'OTP sent to {phone}'**
  String otpSentTo(String phone);

  /// Overlay message displayed while the scanned code is being processed
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingScan;

  /// Message shown after a QR code is detected
  ///
  /// In en, this message translates to:
  /// **'Scanned code: {code}'**
  String scannedCodeMessage(String code);

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
