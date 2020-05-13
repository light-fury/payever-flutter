import 'employees.dart';

class EmployeesList {
  final int total;
  final int perPage;
  final int number;
  final List<Employees> employees;

  EmployeesList({this.total, this.perPage, this.number, this.employees});

  factory EmployeesList.fromMap(employeesData) {
    List<Employees> employeesDataList = List<Employees>();
    if (employeesData['employees'] != null &&
        employeesData['employees'] != []) {
      var employeesList = employeesData['employees'] as List;
      employeesDataList =
          employeesList.map((data) => Employees.fromMap(data)).toList();
    }

    return EmployeesList(
        total: employeesData['total'],
        perPage: employeesData['perPage'],
        number: employeesData['number'],
        employees: employeesDataList);
  }
}
