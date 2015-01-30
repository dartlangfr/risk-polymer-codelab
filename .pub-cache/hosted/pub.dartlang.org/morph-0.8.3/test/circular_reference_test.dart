part of morph_test;

class CircularOne {
  CircularTwo two;
}

class CircularTwo {
  CircularThree three;
}

class CircularThree {
  CircularOne one;
  
  CircularTwo two;
}

// TODO(diego): Test deeper circular reference check
void circularReferenceTest() {
  var morph = new Morph();
  var one;
  var two;
  var three;
  
  group("Circular reference:", () {
    setUp(() {
      one = new CircularOne();
      two = new CircularTwo();
      three = new CircularThree();
      
      one.two = two;
      two.three = three;
    });
    
    test("Direct circular reference throws ArgumentError", () {
      three.one = one;
      
      var serialization = () {
        morph.serialize(one);
      };
      
      expect(serialization, throwsException);
    });
    
    test("Indirect circular reference throws Exception", () {
      three.two = two;
      
      var serialization = () {
        morph.serialize(one);
      };
      
      expect(serialization, throwsException);
    });
  });
}