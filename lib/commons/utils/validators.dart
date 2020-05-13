import 'dart:async';

class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  static isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static isValidPassword(String password) {
    return _passwordRegExp.hasMatch(password);
  }

  static isValidField(String field) {
    return field.length > 0;
  }

  final validateEmail =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (_emailRegExp.hasMatch(email)) {
      sink.add(email);
    } else {
      sink.addError('Enter a valid email');
    }
  });

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
//        if (_passwordRegExp.hasMatch(password)) {
    if (password.length > 6) {
      sink.add(password);
    } else {
      sink.addError('Invalid password, please enter more than 6 characters');
    }
  });

  final validateField =
      StreamTransformer<String, String>.fromHandlers(handleData: (field, sink) {
    if (field.length > 0) {
      sink.add(field);
    } else {
      sink.addError('Field can\'t be empty');
    }
  });

  isValidList(List<String> employees) {
    return employees.length > 0;
  }

//  final validateList = StreamTransformer<List<String>, List<String>>.fromHandlers(
//      handleData: (employeesList, sink) {
//    if (employeesList.length > 0) {
//      sink.add(employeesList);
//    } else {
//      sink.add([]);
//    }
//  });

  final validateList = StreamTransformer<List<String>, String>.fromHandlers(
      handleData: (employeesList, sink) {
    if (employeesList.length > 0) {
      sink.add("OK");
    } else {
      sink.addError("Error");
    }
  });
}
