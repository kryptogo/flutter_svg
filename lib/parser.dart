import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart' as xml show parseEvents;

import 'src/svg/parser_state.dart';
import 'src/svg/theme.dart';
import 'src/vector_drawable.dart';

/// Parses SVG data into a [DrawableRoot].
class SvgParser {
  /// Parses SVG from a string to a [DrawableRoot] with the provided [theme].
  ///
  /// The [key] parameter is used for debugging purposes.
  ///
  /// By default SVG parsing will only log warnings when detecting unsupported
  /// elements in an SVG.
  /// If [warningsAsErrors] is true the function will throw with an error
  /// instead.
  /// You might want to set this to true for test and to false at runtime.
  /// Defaults to false.
  Future<DrawableRoot> parse(
    String str, {
    SvgTheme theme = const SvgTheme(),
    String? key,
    bool warningsAsErrors = false,
  }) async {
    final String pureStr = str.replaceFirst(RegExp(r'^([\w\s]*)\<svg'), '<svg');
    final XmlDocument document = XmlDocument.parse(pureStr);
    final Iterable<XmlElement> defs = document.findAllElements('defs').toList();
    // document.children[0].children.removeWhere((element){
    // });
    bool isSvg = false;
    if (document.children.isNotEmpty) {
      if (document.children[0] is XmlElement) {
        if ((document.children[0] as XmlElement).name.toString() == 'svg') {
          isSvg = true;
        }
      }
    }

    if (isSvg) {
      document.children[0].children.removeWhere((XmlNode element) {
        if (element is XmlElement) {
          return element.name.toString() == 'defs';
        }
        return false;
      });
      for (XmlElement def in defs) {
        document.children[0].children.insert(0, def.copy());
      }
    }

    final SvgParserState state = SvgParserState(
        xml.parseEvents(document.toString()), theme, key, warningsAsErrors);
    return await state.parse();
  }
}
