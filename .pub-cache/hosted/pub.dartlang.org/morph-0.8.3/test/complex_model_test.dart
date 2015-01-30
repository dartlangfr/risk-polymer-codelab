part of morph_test;


class ComplexModel {
  int integer;
  List<SimpleModel> modelList;
  Map<String, DateTime> dateMap;
  Map<String, SimpleModel> modelMap;
  Map<String, List<SimpleModel>> modelListMap;
}

void complexModelTest() {
  var morph = new Morph();
  var now = new DateTime.now();
  var today = now.toString().replaceFirst(' ', 'T');
  var tomorrow = 
      now.add(new Duration(days: 1)).toString().replaceFirst(' ', 'T');
  
  var map = {
    'integer':    42,
    'modelList':  [ { 'string': 'a string', 'flag': true }, 
                    { 'string': 'another string', 'float': 1.23 } ],
    'dateMap':    { 'Today': today, 'Tomorrow': tomorrow },
    'modelMap':    { 'first': { 'string': 'first model', 'integer': 1 } },
    'modelListMap':  { 'first': [ { 'string': 'first model' }, 
                                  { 'string': 'second model', 'float': 1.23 }] }
  };

  group('Complex model:', () {
    test('Assign model from map', () {
      var model = morph.deserialize(ComplexModel, map);

      expect(model.integer, equals(42));
      expect(model.modelList.length, equals(2));
      expect(model.modelList[1].float, equals(1.23));
      expect(model.dateMap['Today'], equals(now));
      expect(model.modelMap['first'].integer, equals(1));
      expect(model.modelListMap['first'].length, equals(2));
      expect(model.modelListMap['first'][1].string, equals('second model'));
    });

    test('Extract model to map', () {
      var model = new ComplexModel()
        ..integer    = 42
        ..dateMap    = { 'Today': now, 'Tomorrow': now.add(new Duration(days: 1)) }
        ..modelMap    = { 'first': new SimpleModel()..string = 'first model'..integer = 1 }
        ..modelList    = [
          new SimpleModel()..string = 'a string'..flag = true,
          new SimpleModel()..string = 'another string'..float = 1.23
        ]
        ..modelListMap  = { 'first': [
          new SimpleModel()..string = 'first model',
          new SimpleModel()..string = 'second model'..float = 1.23
        ]};

      expect(morph.serialize(model), equals(map));
    });
  });
}
