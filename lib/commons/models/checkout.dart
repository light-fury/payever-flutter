import '../utils/utils.dart';

class Section {
  String code;
  bool enabled;
  bool fixed;
  num order;
  List<dynamic> excludedChannels = List();

  Section.toMap(dynamic obj) {
    code = obj[GlobalUtils.DB_CHECKOUT_SECTIONS_CODE];
    enabled = obj[GlobalUtils.DB_CHECKOUT_SECTIONS_ENABLED];
    fixed = obj[GlobalUtils.DB_CHECKOUT_SECTIONS_FIXED];
    order = obj[GlobalUtils.DB_CHECKOUT_SECTIONS_ORDER];
    print("Section $code enabled $enabled");
    var _excludedChannels = obj[GlobalUtils.DB_CHECKOUT_SECTIONS_EXCLUDED];
    if (_excludedChannels.isNotEmpty) {
      _excludedChannels.forEach((channel) {
        excludedChannels.add(channel);
      });
    }
  }
}

class Checkout {
  List<Section> sections = List();

  Checkout.toMap(dynamic obj) {
    var _sections = obj[GlobalUtils.DB_CHECKOUT_SECTIONS];
    if (_sections.isNotEmpty) {
      _sections.forEach((section) {
        sections.add(Section.toMap(section));
      });
    }
  }
}
