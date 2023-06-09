import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../database/api_key_storage_helper.dart';
import '../bottom_sheets/settings_bottom_sheet.dart';

class SettingsButton extends StatefulWidget {
  final APIKeyStorageHelper apiKeyStorageHelper;

  const SettingsButton({super.key, required this.apiKeyStorageHelper});

  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    double width = MediaQuery.of(context).size.width;

    return NeumorphicButton(
      padding: EdgeInsets.all(width * 0.03),
      minDistance: -5,
      style: NeumorphicStyle(
        lightSource: LightSource.topLeft,
        intensity: provider.theme == ThemeMode.light ? .8 : .4,
        color: colorScheme.primary,
        shadowLightColor: Colors.white,
        shadowDarkColor: Colors.black,
        shadowLightColorEmboss: Colors.white,
        shadowDarkColorEmboss: Colors.black,
        depth: provider.theme == ThemeMode.light ? 9 : 3,
        shape: NeumorphicShape.concave,
        surfaceIntensity: .5,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(50)),
      ),
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();

        showModalBottomSheet(
          context: context,
          backgroundColor: colorScheme.primary,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: colorScheme.secondary, strokeAlign: 5, width: 5),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(0),
            ),
          ),
          builder: (BuildContext context) {
            return SettingsBottomSheet(
              apiKeyStorageHelper: widget.apiKeyStorageHelper,
            );
          },
        );
      },
      child: const FaIcon(FontAwesomeIcons.sliders),
    );
  }
}
