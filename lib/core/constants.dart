class AppConstants {
  static const appName = 'NeuraAster';
  static const apiBaseUrl = 'https://breach-fog-list.ngrok-free.dev';

  static const chatPath = '/api/chat';
  static const ttsPath = '/api/tts';
  static const clearPath = '/api/clear';

  static const defaultModel = '3.1 Pro';
  static const defaultGender = 'female';

  static const supportedModels = <ModelOption>[
    ModelOption('3.5 Flash-Lite', 'Fastest answers'),
    ModelOption('3.8 Flash', 'All-around help'),
    ModelOption('3.1 Pro', 'Advanced reasoning'),
  ];
}

class ModelOption {
  final String name;
  final String subtitle;
  const ModelOption(this.name, this.subtitle);
}
