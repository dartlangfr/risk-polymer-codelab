library risk_engine;

import 'dart:convert';
import 'dart:math';
// Declare libraries needed for Polymer in dart2js version
// risk should be declared in risk library but it's here just for exercise simplification
@MirrorsUsed(targets: const ['risk_engine', 'risk_engine.client', 'risk'])
import 'dart:mirrors';

import 'package:observe/observe.dart';
import 'package:morph/morph.dart';

// Common sources between client and server
part 'src/event.dart';
part 'src/event_codec.dart';
part 'src/game.dart';
part 'src/map.dart';
