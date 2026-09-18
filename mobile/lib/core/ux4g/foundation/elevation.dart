import 'package:flutter/material.dart';
import 'shadow.dart';

@Deprecated('Use Ux4gShadow instead')
class Ux4gElevation {
  @Deprecated('Use Ux4gShadow.shadow0 instead')
  static const List<BoxShadow> elevation0 = Ux4gShadow.shadow0;
  
  @Deprecated('Use Ux4gShadow.flat instead')
  static const List<BoxShadow> flat = Ux4gShadow.flat;

  @Deprecated('Use Ux4gShadow.shadow1 instead')
  static const List<BoxShadow> elevation1 = Ux4gShadow.shadow1;
  
  @Deprecated('Use Ux4gShadow.subtle instead')
  static const List<BoxShadow> subtle = Ux4gShadow.subtle;

  @Deprecated('Use Ux4gShadow.shadow2 instead')
  static const List<BoxShadow> elevation2 = Ux4gShadow.shadow2;
  
  @Deprecated('Use Ux4gShadow.floating instead')
  static const List<BoxShadow> floating = Ux4gShadow.floating;

  @Deprecated('Use Ux4gShadow.shadow3 instead')
  static const List<BoxShadow> elevation3 = Ux4gShadow.shadow3;
  
  @Deprecated('Use Ux4gShadow.prominent instead')
  static const List<BoxShadow> prominent = Ux4gShadow.prominent;

  @Deprecated('Use Ux4gShadow.shadow4 instead')
  static const List<BoxShadow> elevation4 = Ux4gShadow.shadow4;
  
  @Deprecated('Use Ux4gShadow.highest instead')
  static const List<BoxShadow> highest = Ux4gShadow.highest;

  @Deprecated('Use Ux4gShadow.get() instead')
  static List<BoxShadow> get(int level, {bool isDark = false}) {
    return Ux4gShadow.get(level, isDark: isDark);
  }
}
