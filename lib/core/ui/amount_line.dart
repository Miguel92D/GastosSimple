import 'package:flutter/widgets.dart';

/// Alto fijo del renglón de un monto de [fontSize] (D-030): la tarjeta mide
/// lo mismo aunque un monto muy largo tenga que achicarse para entrar.
double amountLineHeight(BuildContext context, double fontSize) =>
    MediaQuery.textScalerOf(context).scale(fontSize) * 1.3;
