// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:file_picker/file_picker.dart';

part 'elements/dependency_check_section/dependency_check_section.dart';

class PublishingServices extends StatelessWidget {
  const PublishingServices({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Publising Services',
      theme: ThemeData(
        brightness: SchedulerBinding.instance.window.platformBrightness,
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16,
          ),
          bodyText2: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      home: const _PublishingRoute(),
    );
  }
}

class _FlutterConfig {
  String channel;
  String? version;
  bool update;

  _FlutterConfig({
    required this.channel,
    required this.version,
    required this.update,
  });
}

class _ClickapoIosConfig {
  bool build, upload, updateBuildNumber;

  _ClickapoIosConfig({
    required this.build,
    required this.upload,
    required this.updateBuildNumber,
  });
}

class _AndroidBuildModes {
  bool debug, profile, release;

  _AndroidBuildModes({
    this.debug = true,
    this.profile = true,
    this.release = true,
  });
}

class _ClickapoAndroidConfig {
  bool build, upload, updateBuildNumber, firebaseUpload;
  _AndroidBuildModes buildModes;

  _ClickapoAndroidConfig({
    required this.build,
    required this.firebaseUpload,
    required this.upload,
    required this.updateBuildNumber,
    required this.buildModes,
  });
}

class _ClickapoJsonConfig {
  String channel;
  String? version;
  bool sdkUpdate;
  _ClickapoIosConfig iosConfig;
  _ClickapoAndroidConfig androidConfig;

  _ClickapoJsonConfig({
    required this.channel,
    required this.version,
    required this.sdkUpdate,
    required this.androidConfig,
    required this.iosConfig,
  });

  final List<String> buildArgs = const <String>[];
}

class _CustomSwitch extends StatefulWidget {
  final String label;
  final String? hint;
  final bool value;
  final Function(bool) onValueChanged;
  final bool disabled;

  const _CustomSwitch({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    required this.onValueChanged,
    this.disabled = false,
  });

  @override
  State<_CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<_CustomSwitch> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
  }

  Color get _color => _selected ? Colors.green : Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.hint,
      padding: const EdgeInsets.all(12),
      child: InkWell(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                _selected ? Icons.check_box : Icons.check_box_outline_blank,
                color: _color,
              ),
            ),
            Text(
              widget.label,
              style: (_selected ? Theme.of(context).textTheme.bodyText2 : Theme.of(context).textTheme.bodyText1)!.copyWith(
                fontWeight: _selected ? FontWeight.bold : null,
                color: _color,
                fontSize: 18,
              ),
            ),
          ],
        ),
        onTap: () async {
          await widget.onValueChanged(!_selected);
          setState(() => _selected = !_selected);
        },
      ),
    );
  }
}

class _PublishingRoute extends StatefulWidget {
  const _PublishingRoute({super.key});

  @override
  State<_PublishingRoute> createState() => __PublishingRouteState();
}

class __PublishingRouteState extends State<_PublishingRoute> {
  static const _flutterConfigLabels = <String>{
    'SDK update',
  };

  static const _flutterConfigHints = <String>{
    'Run flutter upgrade --force\n\n'
        'This command gets the most recent version of the Flutter SDK that\'s available on your current Flutter channel.',
  };

  static const _flutterChannelLabels = <String>{
    'stable',
    'dev',
    'beta',
    'master',
  };

  static final _buildActionLabels = <String>{
    'iOS',
    'Android',
  };

  static final _buildActionsHints = <String>{
    'Perform iOS build actions',
    'Perform Android build actions',
  };

  static const _iosLabels = <String>{
    'Upload to Testflight',
    'Update build number',
  };

  static const _iosHints = <String>{
    'Uploads the app archive to Testflight. Compliance status must be manually declared through appstoreconnect.apple.com',
    'Edit Info.plist configuration file',
  };

  static const _androidLabels = <String>{
    'Upload to Firebase',
    'Submit for Google Play review',
    'Update build number',
  };

  static const _androidHints = <String>{
    'Uploads the debug, profile, and release builds through Firebase App Publishing service',
    'Submit the app bundle to the release track and send it to review',
    'Edit build.gradle configuration file',
  };

  final _flutterConfig = _FlutterConfig(
    channel: _flutterChannelLabels.elementAt(3),
    update: false,
    version: null,
  );

  final _iosConfig = _ClickapoIosConfig(
    build: io.Platform.isMacOS,
    upload: io.Platform.isMacOS,
    updateBuildNumber: false,
  );

  final _androidConfig = _ClickapoAndroidConfig(
    build: true,
    firebaseUpload: true,
    upload: false,
    updateBuildNumber: false,
    buildModes: _AndroidBuildModes(),
  );

  late _ClickapoJsonConfig _config;

  @override
  void initState() {
    super.initState();
    _config = _ClickapoJsonConfig(
      channel: _flutterConfig.channel,
      version: null,
      sdkUpdate: _flutterConfig.update,
      iosConfig: _iosConfig,
      androidConfig: _androidConfig,
    );
  }

  Timer? _infoControllerTimer;
  final _infoController = StreamController<String?>.broadcast();
  void _displayInfo(String infoMessage) {
    _infoControllerTimer?.cancel();
    _infoController.add(infoMessage);
    _infoControllerTimer = Timer(
      const Duration(seconds: 8),
      () => _infoController.add(null),
    );
    throw 'Unsupported';
  }

  final _buildArgsController = StreamController<List<String>>.broadcast();

  final _logs = <Map<String, String>>[];

  final _publishScriptController = StreamController<String>.broadcast();

  void _stdinf(value) {
    _logs.add({'stdinf': '${'\n\n' + value}\n\n\n'});
    _publishScriptController.add(value);
  }

  void _stdout(value) {
    _logs.add({'stdout': value});
    _publishScriptController.add(value);
  }

  void _stderr(value, [bool throwException = false]) {
    _logs.add({'stderr': value});
    _publishScriptController.add(value);
    if (throwException) throw value;
  }

  io.ProcessResult? _result;

  Future<void> _runInteractive(String command, [String? workingDirectory]) async {
    final split = command.split(' ');
    final cmd = split[0];
    split.removeAt(0);
    final process = await io.Process.start(cmd, split, runInShell: true, workingDirectory: workingDirectory);
    process.stderr.transform(utf8.decoder).forEach((e) => _stderr(e));
    process.stdout.transform(utf8.decoder).forEach((e) => _stdout(e));
    final exitCode = await process.exitCode;
    _stdinf('$command exit with code: $exitCode');
  }

  Future<void> _checkDependencies(Set<String> dependencies) async {
    for (String dependency in dependencies) {
      _result = await io.Process.run(io.Platform.isWindows ? 'gcm' : 'which', [dependency], runInShell: true);
      if (_result!.stderr != null) _stderr(_result!.stderr);
      if (_result!.stdout != null) _stdout(_result!.stdout);
    }
  }

  Future<void> _run(String command, [String? workingDirectory]) async {
    final split = command.split(' ');
    final executable = split[0];
    split.removeAt(0);
    _result = await io.Process.run(executable, split, runInShell: true, workingDirectory: workingDirectory);
    if (_result!.stderr != null) _stderr(_result!.stderr);
    if (_result!.stdout != null) _stdout(_result!.stdout);
  }

  bool _running = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(26, 30, 26, 20),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Text(
                  'Bash / ZSH automated publishing support',
                  style: TextStyle(
                    fontSize: 26,
                  ),
                ),
              ),
              const _DependencyCheckSection(),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Flutter config',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 10),
                child: Row(
                  children: [
                    for (int i = 0; i < _flutterConfigLabels.length; i++)
                      Padding(
                        padding: EdgeInsets.only(left: i != 0 ? 24 : 0),
                        child: _CustomSwitch(
                          label: _flutterConfigLabels.elementAt(i),
                          hint: _flutterConfigHints.elementAt(i),
                          value: _config.sdkUpdate,
                          onValueChanged: (value) {
                            switch (i) {
                              case 0:
                                _config.sdkUpdate = value;
                                break;
                              default:
                                return _displayInfo('Not implemented');
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              StatefulBuilder(
                builder: (context, setState) {
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          'Channel:',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      for (int i = 0; i < _flutterChannelLabels.length; i++)
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _flutterChannelLabels.elementAt(i),
                                  style: TextStyle(
                                    fontWeight: _config.channel == _flutterChannelLabels.elementAt(i) ? FontWeight.bold : null,
                                    color: _config.channel == _flutterChannelLabels.elementAt(i) ? Colors.green : null,
                                  ),
                                ),
                                if (_config.channel == _flutterChannelLabels.elementAt(i))
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          onTap: () => setState(() => _config.channel = _flutterChannelLabels.elementAt(i)),
                        ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Build for',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 10),
                child: Row(
                  children: [
                    for (int i = 0; i < _buildActionLabels.length; i++)
                      Padding(
                        padding: EdgeInsets.only(left: i != 0 ? 24 : 0),
                        child: _CustomSwitch(
                          label: _buildActionLabels.elementAt(i),
                          hint: _buildActionsHints.elementAt(i),
                          value: i == 0 && io.Platform.isMacOS,
                          onValueChanged: (value) {
                            switch (i) {
                              case 0:
                                if (!io.Platform.isMacOS) {
                                  _displayInfo('Not running on Mac OS');
                                  throw 0;
                                }
                                _config.iosConfig.build = !_config.iosConfig.build;
                                break;
                              case 1:
                                _config.androidConfig.build = value;
                                break;
                              default:
                                return _displayInfo('Not implemented');
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'iOS config',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 10),
                child: Row(
                  children: [
                    for (int i = 0; i < _iosLabels.length; i++)
                      Padding(
                        padding: EdgeInsets.only(left: i != 0 ? 24 : 0),
                        child: _CustomSwitch(
                          label: _iosLabels.elementAt(i),
                          hint: _iosHints.elementAt(i),
                          value: i == 0,
                          onValueChanged: (value) {
                            switch (i) {
                              case 0:
                                if (!io.Platform.isMacOS) _displayInfo('Not running on Mac OS');
                                _config.iosConfig.upload = !_config.iosConfig.upload;
                                break;
                              case 1:
                                return _displayInfo('TODO');
                              default:
                                return _displayInfo('Not implemented');
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Android config',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 10),
                child: Row(
                  children: [
                    for (int i = 0; i < _androidLabels.length; i++)
                      Padding(
                        padding: EdgeInsets.only(left: i != 0 ? 24 : 0),
                        child: _CustomSwitch(
                          label: _androidLabels.elementAt(i),
                          hint: _androidHints.elementAt(i),
                          value: i == 0,
                          onValueChanged: (value) {
                            switch (i) {
                              case 0:
                                _config.androidConfig.firebaseUpload = !_config.androidConfig.firebaseUpload;
                                break;
                              case 1:
                                _config.androidConfig.upload = !_config.androidConfig.upload;
                                break;
                              case 2:
                                return _displayInfo('TODO');
                              default:
                                return _displayInfo('Not implemented');
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _running ? Colors.red : Theme.of(context).primaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          _running ? 'CANCEL' : 'START BUILD',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    onTap: _running
                        ? () => io.exit(0)
                        : () async {
                            try {
                              setState(() => _running = true);
                              _logs.clear();
                              await _runInteractive(io.Platform.isWindows ? 'dir' : 'pwd');
                              _stdinf('Checking dev dependencies');
                              await _checkDependencies(_DependencyCheckSection.dependencies.elementAt(0));
                              if (_config.sdkUpdate) {
                                _stdinf('Setting SDK channel');
                                await _runInteractive('flutter channel ' + _config.channel);
                                _stdinf('Upgrading Flutter SDK');
                                await _runInteractive('flutter upgrade --force');
                                await _runInteractive('flutter doctor');
                                _stdinf('Static code analysis');
                                await _runInteractive('flutter analyze');
                              }
                              if (io.Platform.isMacOS && _config.iosConfig.build) {
                                _stdinf('Starting iOS build');
                                await _checkDependencies(_DependencyCheckSection.dependencies.elementAt(1));
                                _stdinf('IPA build starting');
                                await _runInteractive('flutter build ipa --dart-define BUILD_ENV=PRODUCTION');
                                _stdinf('Testflight upload starting');
                                await _runInteractive(
                                  'xcodebuild -exportArchive -archivePath ./build/ios/archive/Runner.xcarchive '
                                  '-exportOptionsPlist ./ios/exportOptions.plist -exportPath ./build/ios/archive/',
                                );
                              }
                              if (_config.androidConfig.build) {
                                _stdinf('Starting Android build');
                                await _checkDependencies(_DependencyCheckSection.dependencies.elementAt(2));
                                if (_config.androidConfig.firebaseUpload) {
                                  final buildModes = {'debug', 'profile', 'release'};
                                  for (var mode in buildModes) {
                                    _stdinf('Building $mode mode APK for Firebase upload');
                                    await _runInteractive('flutter build apk --$mode');
                                    _stdinf('Uploading $mode to Firebase');
                                    await _runInteractive(
                                      (io.Platform.isWindows ? '' : './') +
                                          'gradlew appDistributionUpload' +
                                          mode[0].toUpperCase() +
                                          mode.substring(1),
                                      './android',
                                    );
                                  }
                                }
                                if (_config.androidConfig.upload) {
                                  _stdinf('AAB build start');
                                  await _runInteractive('flutter build appbundle --dart-define BUILD_ENV=PRODUCTION');
                                }
                              }
                              setState(() => _running = false);
                              _stdinf('Script exit');
                            } catch (e) {
                              setState(() => _running = false);
                              _stderr('FATAL EXCEPTION: ' + e.toString());
                            }
                          },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 36),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black87,
                  ),
                  child: SizedBox(
                    height: 600,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: StreamBuilder<String>(
                        stream: _publishScriptController.stream,
                        builder: (context, stdout) {
                          return ListView(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            reverse: true,
                            children: [
                              if (_logs.isNotEmpty && _logs.last['stdinf'] != '\n\nScript exit\n\n\n')
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              for (Map<String, String> log in _logs.reversed)
                                SelectableText(
                                  log['stdinf'] ?? log['stdout'] ?? log['stderr']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: log['stdinf'] != null
                                        ? Colors.white
                                        : log['stderr'] != null
                                            ? Colors.red
                                            : Colors.grey,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 24,
            right: 24,
            child: StreamBuilder<String?>(
              stream: _infoController.stream,
              builder: (context, info) {
                return info.hasData
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            info.data!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _infoController.close();
    _buildArgsController.close();
    _publishScriptController.close();
    super.dispose();
  }
}
