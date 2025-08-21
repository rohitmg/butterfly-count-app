import 'package:uuid/uuid.dart';

final Uuid uuid = const Uuid();

String generateId({String prefix = 'id'}) => '${prefix}_${uuid.v4()}';