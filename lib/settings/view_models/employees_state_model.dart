import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../view_models/view_models.dart';
import '../network/network.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class EmployeesStateModel extends ChangeNotifier with Validators {
  final GlobalStateModel globalStateModel;
  final EmployeesApi api;

  EmployeesStateModel(this.globalStateModel, this.api);

  String get accessToken => GlobalUtils.activeToken.accessToken;

  String get businessId => globalStateModel.currentBusiness.id;

  final _firstNameController = BehaviorSubject<String>();
  final _lastNameController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _positionController = BehaviorSubject<String>();
  final _groupController = BehaviorSubject<String>();
  final _employeesSelectionListController = BehaviorSubject<List<String>>();

  Stream<String> get firstName =>
      _firstNameController.stream.transform(validateField);

  Stream<String> get lastName =>
      _lastNameController.stream.transform(validateField);

  Stream<String> get email => _emailController.stream.transform(validateEmail);

  Stream<String> get position =>
      _positionController.stream.transform(validateField);

  Stream<bool> get submitValid => Observable.combineLatest4(
      firstName, lastName, email, position, (a, b, c, d) => true);

  Stream<String> get group => _groupController.stream.transform(validateField);

  Stream<String> get availableEmployeeList =>
      _employeesSelectionListController.stream.transform(validateList);

  Function(String) get changeFirstName => _firstNameController.sink.add;

  Function(String) get changeLastName => _lastNameController.sink.add;

  Function(String) get changeEmail => _emailController.sink.add;

  Function(String) get changePosition => _positionController.sink.add;

  Function(String) get changeGroup => _groupController.sink.add;

  Function(List<String>) get changEmployeeList =>
      _employeesSelectionListController.sink.add;

  String get firstNameValue => _firstNameController.value;

  String get lastNameValue => _lastNameController.value;

  String get emailValue => _emailController.value;

  String get positionValue => _positionController.value;

  String get groupValue => _groupController.value;

  List<String> get employeeListValue => _employeesSelectionListController.value;

  clearEmployeeData() {
    _firstNameController.value = "";
    _lastNameController.value = "";
    _emailController.value = "";
    _positionController.value = "";
    _groupController.value = "";
    _employeesSelectionListController.value = [];
  }

  dispose() {
    _firstNameController.close();
    _lastNameController.close();
    _emailController.close();
    _positionController.close();
    _groupController.close();
    _employeesSelectionListController.close();
    super.dispose();
  }

  List<BusinessApps> _businessApps = List<BusinessApps>();

  List<BusinessApps> get businessApps => _businessApps;

  List<Acl> _aclsList = List<Acl>();

  List<Acl> get aclsList => _aclsList;

  void updateAclsList(
      String microservice, bool create, bool read, bool update, bool delete) {
    aclsList.add(Acl.fromMap({
      "microservice": microservice,
      "create": create,
      "read": read,
      "update": update,
      "delete": delete
    }));
    notifyListeners();
  }

  void updateBusinessApps(List<BusinessApps> businessApps) {
//    _businessApps = [];
    _businessApps = businessApps;
    notifyListeners();
  }

  void updateBusinessAppPermissionCreate(int index, bool value) {
    businessApps[index].allowedAcls.create = value;
    notifyListeners();
  }

  void updateBusinessAppPermissionRead(int index, bool value) {
    businessApps[index].allowedAcls.read = value;
    notifyListeners();
  }

  void updateBusinessAppPermissionUpdate(int index, bool value) {
    businessApps[index].allowedAcls.update = value;
    notifyListeners();
  }

  void updateBusinessAppPermissionDelete(int index, bool value) {
    businessApps[index].allowedAcls.delete = value;
    notifyListeners();
  }

  ///API CALLS
  Future<dynamic> getAppsBusinessInfo() async {
    return api.getAppsBusiness(businessId, accessToken);
  }

  Future<void> createNewEmployee(Object data) async {
    return api.addEmployee(data, accessToken, businessId);
  }

  Future<void> updateEmployee(Object data, String userId) async {
    return api.updateEmployee(data, accessToken, businessId, userId);
  }

  Future<void> addEmployeesToGroup(String groupId, Object data) async {
    return api.addEmployeesToGroup(accessToken, businessId, groupId, data);
  }

  Future<void> deleteEmployeesFromGroup(String groupId, Object data) async {
    return api.deleteEmployeesFromGroup(
        accessToken, businessId, groupId, data);
  }

  Future<void> deleteEmployeeFromBusiness(String userId) async {
    return api.deleteEmployeeFromBusiness(accessToken, businessId, userId);
  }

  Future<void> createNewGroup(Object data) async {
    return api.addNewGroup(data, accessToken, businessId);
  }

  Future<void> deleteGroup(String groupId) async {
    return api.deleteGroup(accessToken, businessId, groupId);
  }

  Future<dynamic> getEmployeesFromGroup(String groupId) async {
    return api.getBusinessEmployeesGroup(accessToken, businessId, groupId);
  }

}
