import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/features/auth/bloc/auth_bloc.dart';
import 'presentation/features/wallet/bloc/wallet_bloc.dart';
import 'presentation/features/voucher/bloc/voucher_bloc.dart';
import 'presentation/features/redemption/bloc/redemption_bloc.dart';
import 'presentation/features/purchase/bloc/purchase_bloc.dart';
import 'presentation/features/business/bloc/business_bloc.dart';
import 'presentation/features/localization/bloc/localization_bloc.dart';
import 'presentation/features/localization/bloc/localization_event.dart';
import 'presentation/features/localization/bloc/localization_state.dart';
import 'presentation/widgets/localized_app.dart';
import 'di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await configureDependencies();
  
  runApp(const RabaisApp());
}

class RabaisApp extends StatelessWidget {
  const RabaisApp({super.key});

  @override
  Widget build(BuildContext context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<AuthBloc>()),
            BlocProvider(create: (context) => getIt<WalletBloc>()),
            BlocProvider(create: (context) => getIt<VoucherBloc>()),
            BlocProvider(create: (context) => getIt<RedemptionBloc>()),
            BlocProvider(create: (context) => getIt<PurchaseBloc>()),
            BlocProvider(create: (context) => getIt<BusinessBloc>()),
            BlocProvider(create: (context) {
              final bloc = LocalizationBloc();
              bloc.add(const LoadLanguageEvent());
              return bloc;
            }),
          ],
      child: RestartWidget(
        child: BlocBuilder<LocalizationBloc, LocalizationState>(
          builder: (context, state) {
            Locale locale = const Locale('fr'); // Default to French
            
            if (state is LocalizationLoaded) {
              locale = state.locale;
              print('Main: Using locale: ${locale.languageCode}');
            } else {
              print('Main: Using default locale: ${locale.languageCode}');
            }
            
            return LocalizedApp(
              locale: locale,
            );
          },
        ),
      ),
    );
  }
}