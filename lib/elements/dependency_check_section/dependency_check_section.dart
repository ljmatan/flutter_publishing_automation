part of 'publishing_services.dart';

class _DependencyEntry extends StatefulWidget {
  final String dependency;

  const _DependencyEntry({
    super.key,
    required this.dependency,
  });

  @override
  State<StatefulWidget> createState() {
    return _DependencyEntryState();
  }
}

class _DependencyEntryState extends State<_DependencyEntry> {
  Key _futureKey = UniqueKey();

  Future<io.ProcessResult> _checkDependency() async {
    return await io.Process.run('which', [widget.dependency]).then((value) {
      if (value.stdout == null || value.stdout == '') throw 'Not found';
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<io.ProcessResult>(
      key: _futureKey,
      future: _checkDependency(),
      builder: (context, result) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                Row(
                  children: [
                    Tooltip(
                      message: 'Select path',
                      child: InkWell(
                        child: const Icon(
                          Icons.folder_open,
                          color: Colors.grey,
                        ),
                        onTap: () async {
                          if (result.hasError) {
                            setState(() => _futureKey = UniqueKey());
                            Future.delayed(const Duration(milliseconds: 100), () async {
                              if (!result.hasError) {
                                final path = await FilePicker.platform.getDirectoryPath();
                                if (path != null) print(path);
                              }
                            });
                          } else {
                            final path = await FilePicker.platform.getDirectoryPath();
                            if (path != null) print(path);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(widget.dependency),
                    ),
                    Text(
                      result.error?.toString() ??
                          (result.data?.stdout == null ? (result.data?.stderr ?? '') : result.data?.stdout?.replaceAll('\n', '') ?? ''),
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: result.hasError ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DependencyCheckSection extends StatelessWidget {
  const _DependencyCheckSection({super.key});

  static final dependencyTypes = <String>{
    'Dev',
    if (io.Platform.isMacOS) 'iOS',
    'Android',
  };

  static final dependencies = <Set<String>>{
    {
      'git',
      'flutter',
      'dart',
      'python3',
      'ruby',
      'fastlane',
    },
    if (io.Platform.isMacOS)
      {
        'pod',
        'xcodebuild',
      },
    {
      'java',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dependencies',
          style: Theme.of(context).textTheme.headline5,
        ),
        const Divider(),
        for (int i = 0; i < dependencyTypes.length; i++)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  dependencyTypes.elementAt(i) + ':',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              for (String dependency in dependencies.elementAt(i)) _DependencyEntry(dependency: dependency),
            ],
          ),
      ],
    );
  }
}
