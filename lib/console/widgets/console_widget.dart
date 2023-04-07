import 'package:flutter/material.dart';
import 'package:ztp_projekt/common/shortcuts/intents/save_intent.dart';
import 'package:ztp_projekt/common/utils/color_at_elevation.dart';
import 'package:ztp_projekt/console/command_line.dart';

class ConsoleWidget extends StatefulWidget {
  const ConsoleWidget({
    super.key,
  });

  @override
  State<ConsoleWidget> createState() => _ConsoleWidgetState();
}

class _ConsoleWidgetState extends State<ConsoleWidget> {
  final TextEditingController _historyTextController = TextEditingController();
  final TextEditingController _commandLineTextController =
      TextEditingController();
  final ScrollController _historyScrollController = ScrollController();

  @override
  void initState() {
    _historyTextController.text =
        '[BookShelf v1] database initialized \ntype "help" for more information';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Actions(
      actions: <Type, Action<Intent>>{
        SaveIntent: CallbackAction<SaveIntent>(
          onInvoke: (SaveIntent intent) {
            _onSave(_commandLineTextController.text);
            return null;
          },
        ),
      },
      child: Container(
        height: 200,
        color: colorScheme.surface.withSurfaceTint(context, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 1,
              color: colorScheme.surface.withSurfaceTint(context, 12),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _historyScrollController,
                child: TextFormField(
                  controller: _historyTextController,
                  readOnly: true,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16) +
                        const EdgeInsets.only(bottom: 16, top: 8),
                  ),
                ),
              ),
            ),
            ConsolePrompt(
              controller: _commandLineTextController,
              onSubmit: _onSave,
            ),
          ],
        ),
      ),
    );
  }

  void _onSave(String value) {
    _historyTextController.text +=
        '\n> $value \ncommand not recognized\ntype "help" for more information';
    _commandLineTextController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _historyScrollController.animateTo(
        _historyScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }
}