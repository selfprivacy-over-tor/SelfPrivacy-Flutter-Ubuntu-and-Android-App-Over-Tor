import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfprivacy/config/app_controller/inherited_app_controller.dart';
import 'package:selfprivacy/config/bloc_config.dart';
import 'package:selfprivacy/config/bloc_observer.dart';
import 'package:selfprivacy/config/brand_colors.dart';
import 'package:selfprivacy/config/get_it_config.dart';
import 'package:selfprivacy/config/hive_config.dart';
import 'package:selfprivacy/config/localization.dart';
import 'package:selfprivacy/config/preferences_repository/datasources/preferences_hive_datasource.dart';
import 'package:selfprivacy/config/preferences_repository/inherited_preferences_repository.dart';
import 'package:selfprivacy/logic/get_it/resources_model.dart';
import 'package:selfprivacy/logic/models/hive/server.dart';
import 'package:selfprivacy/logic/models/hive/server_details.dart';
import 'package:selfprivacy/logic/models/hive/server_domain.dart';
import 'package:selfprivacy/ui/pages/errors/failed_to_init_secure_storage.dart';
import 'package:selfprivacy/ui/router/router.dart';
import 'package:hive_ce/hive.dart';
import 'package:timezone/data/latest.dart' as tz;

/// Development auto-setup: pre-seed connection data for Tor .onion VM.
/// Only runs in debug mode and only if no server is already configured.
/// Mimics what saveHasFinalChecked() does: populates ResourcesModel
/// and clears WizardDataModel so load() returns ServerInstallationFinished.
Future<void> _devAutoSetup() async {
  if (!kDebugMode) return;

  const onionDomain =
      String.fromEnvironment('ONION_DOMAIN', defaultValue: '');
  const apiToken =
      String.fromEnvironment('API_TOKEN', defaultValue: '');

  // ignore: avoid_print
  print('[DEV] Auto-setup: onionDomain=$onionDomain, apiToken=${apiToken.isNotEmpty ? "SET" : "EMPTY"}');

  if (onionDomain.isEmpty || apiToken.isEmpty) return;

  final resourcesModel = getIt<ResourcesModel>();

  // Skip if already configured, but ensure onboarding is disabled
  if (resourcesModel.servers.isNotEmpty) {
    // ignore: avoid_print
    print('[DEV] Auto-setup: already configured, ensuring onboarding disabled');
    final appSettingsBox = Hive.box(BNames.appSettingsBox);
    await appSettingsBox.put(BNames.shouldShowOnboarding, false);
    return;
  }

  // ignore: avoid_print
  print('[DEV] Auto-setup: connecting to $onionDomain');

  final serverDomain = ServerDomain(
    domainName: onionDomain,
    provider: DnsProviderType.unknown,
  );
  final serverDetails = ServerHostingDetails(
    apiToken: apiToken,
    ip4: onionDomain,
    id: 0,
    createTime: null,
    startTime: null,
    provider: ServerProviderType.unknown,
    volume: ServerProviderVolume(
      id: 0,
      name: 'tor-vm',
      sizeByte: 10737418240,
      serverId: 0,
      linuxDevice: '',
    ),
  );

  // Add server to ResourcesModel (same as saveHasFinalChecked)
  await resourcesModel.addServer(Server(
    domain: serverDomain,
    hostingDetails: serverDetails,
  ));

  // Ensure wizard data is cleared (null) so load() takes the
  // "wizardData == null, servers not empty" path → ServerInstallationFinished
  await getIt<WizardDataModel>().clearServerInstallation();

  // Disable onboarding screen so the app goes straight to dashboard
  final appSettingsBox = Hive.box(BNames.appSettingsBox);
  await appSettingsBox.put(BNames.shouldShowOnboarding, false);

  // Re-initialize API connection now that server details are populated
  // (The initial init() during getItSetup() returned early because
  // serverDetails was null at that point)
  await getIt<ApiConnectionRepository>().init();

  // ignore: avoid_print
  print('[DEV] Auto-setup complete. servers=${resourcesModel.servers.length}, wizardData=${getIt<WizardDataModel>().serverInstallation}');
}

void main() async {
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // try {
  //   /// Wakelock support for Linux
  //   /// desktop is not yet implemented
  //   await Wakelock.enable();
  // } on PlatformException catch (e) {
  //   print(e);
  // }

  try {
    await Future.wait(<Future<void>>[
      HiveConfig.init(),
      EasyLocalization.ensureInitialized(),
    ]);
    await getItSetup();
    await _devAutoSetup();
  } on PlatformException catch (e) {
    runApp(FailedToInitSecureStorageScreen(e: e));
  }

  tz.initializeTimeZones();

  Bloc.observer = SimpleBlocObserver();

  runApp(
    Localization(
      child: InheritedPreferencesRepository(
        dataSource: PreferencesHiveDataSource(),
        child: const InheritedAppController(child: AppBuilder()),
      ),
    ),
  );
}

class AppBuilder extends StatelessWidget {
  const AppBuilder({super.key});

  @override
  Widget build(final BuildContext context) {
    final appController = InheritedAppController.of(context);

    if (appController.loaded) {
      return const SelfprivacyApp();
    }

    return const SplashScreen();
  }
}

/// Widget to be shown
/// until essential app initialization is completed
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(final BuildContext context) => const ColoredBox(
    color: Colors.white,
    child: Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation(BrandColors.primary),
      ),
    ),
  );
}

class SelfprivacyApp extends StatefulWidget {
  const SelfprivacyApp({super.key});

  @override
  State<SelfprivacyApp> createState() => _SelfprivacyAppState();
}

class _SelfprivacyAppState extends State<SelfprivacyApp> {
  final appKey = UniqueKey();
  final _appRouter = RootRouter(getIt.get<NavigationService>().navigatorKey);

  @override
  Widget build(final BuildContext context) {
    final appController = InheritedAppController.of(context);

    return BlocAndProviderConfig(
      child: MaterialApp.router(
        key: appKey,
        title: 'SelfPrivacy',
        // routing
        routeInformationParser: _appRouter.defaultRouteParser(),
        routerDelegate: _appRouter.delegate(),
        scaffoldMessengerKey:
            getIt.get<NavigationService>().scaffoldMessengerKey,
        // localization settings
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        // theme settings
        themeMode: appController.themeMode,
        theme: appController.lightTheme,
        darkTheme: appController.darkTheme,
        // other preferences
        debugShowCheckedModeBanner: false,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          scrollbars: false,
        ),
        builder: _builder,
      ),
    );
  }

  Widget _builder(final BuildContext context, final Widget? widget) {
    Widget error = const Center(child: Text('...rendering error...'));
    if (widget is Scaffold || widget is Navigator) {
      error = Scaffold(body: error);
    }
    ErrorWidget.builder = (final FlutterErrorDetails errorDetails) => error;

    return widget ?? error;
  }
}
