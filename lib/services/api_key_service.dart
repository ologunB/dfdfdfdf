import 'app_provisioning.dart';
import 'constants.dart';

class ApiKeyService {
  // ignore: do_not_use_environment
  static const envKey = String.fromEnvironment(Constants.ablyApiKey);
  static const defaultEnvKeyPlaceholder =
      '9hmcFw.VOIRxg:2ZN1S8tYYmNrjlrfWzA5s22x6tTq-FzxoUUuvGSS3Y4';

  Future<ApiKeyProvision> getOrProvisionApiKey() async {
    if (envKey.isNotEmpty && envKey != defaultEnvKeyPlaceholder) {
      return ApiKeyProvision(
        key: envKey,
        source: ApiKeySource.env,
      );
    } else {
      final provisionedKey = await AppProvisioning().provisionApp();
      return ApiKeyProvision(
        key: provisionedKey,
        source: ApiKeySource.testProvision,
      );
    }
  }
}

class ApiKeyProvision {
  String key;

  ApiKeySource source;

  ApiKeyProvision({
    required this.key,
    required this.source,
  });
}

enum ApiKeySource {
  env,
  testProvision,
}
