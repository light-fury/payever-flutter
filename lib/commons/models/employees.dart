import 'acl.dart';

class Employees {
  final List<UserRoles> roles;
  final List<EmployeeGroup> groups;
  final String id;
  final bool isVerified;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String createdAt;
  final String updatedAt;
  final int v;

//  final List<EmployeePosition> position;
  final String position;
  final String idAgain;
  final int status;

  Employees(
      {this.roles,
      this.groups,
      this.id,
      this.isVerified,
      this.firstName,
      this.lastName,
      this.fullName,
      this.email,
      this.createdAt,
      this.updatedAt,
      this.v,
      this.position,
      this.idAgain,
      this.status});

  factory Employees.fromMap(dynamic obj) {
    List<UserRoles> rolesDataList = List<UserRoles>();
    if (obj['roles'] != null && obj['roles'] != []) {
      var rolesData = obj['roles'] as List;
      rolesDataList = rolesData.map((data) => UserRoles.fromMap(data)).toList();
    }

    List<EmployeeGroup> employeeGroupDataList = List<EmployeeGroup>();
    if (obj['groups'] != null && obj['groups'] != []) {
      var groupsData = obj['groups'] as List;
      employeeGroupDataList =
          groupsData.map((data) => EmployeeGroup.fromMap(data)).toList();
    }

    return Employees(
      roles: rolesDataList,
      groups: employeeGroupDataList,
      firstName: obj['first_name'],
      lastName: obj['last_name'],
      fullName: obj['fullName'],
      position: obj['position'],
      email: obj['email'],
      id: obj['_id'],
      status: obj['status'] ?? 1,
    );
  }
}

class EmployeePosition {
  final String businessId;
  final String positionType;

  EmployeePosition({this.businessId, this.positionType});

  factory EmployeePosition.fromMap(dynamic obj) {
    return EmployeePosition(
        businessId: obj['businessId'], positionType: obj['positionType']);
  }
}

enum Positions { Cashier, Sales, Marketing, Staff, Admin, Others }

class UserRoles {
  final List<UserPermissions> permission;
  final String type;

//  final String id;
//  final RoleType type;

  UserRoles({this.permission, this.type});

  factory UserRoles.fromMap(role) {
    print("role: $role");

    List<UserPermissions> permissionsDataList = [];
    if (role['permissions'] != []) {
      var permissionsData = role['permissions'] as List;
      permissionsDataList =
          permissionsData.map((data) => UserPermissions.fromMap(data)).toList();
    }

    return UserRoles(
      permission: permissionsDataList,
//      id: role['_id'],
//      type: RoleType.fromMap(role['type']),
      type: role['type'],
    );
  }
}

class UserPermissions {
//  final String id;
  final List<Acl> acls;
  final String businessId;

//  final bool hasAcls;
//  final int v;

//  UserPermissions({this.id, this.businessId, this.acls, this.hasAcls, this.v});
  UserPermissions({this.acls, this.businessId});

  factory UserPermissions.fromMap(permissions) {
    var aclsData = permissions['acls'] as List;
    List<Acl> aclsDataList = aclsData.map((data) => Acl.fromMap(data)).toList();

    return UserPermissions(
      businessId: permissions['businessId'],
      acls: aclsDataList,
//      id: permissions['_id'] ?? "",
//      hasAcls: permissions['hasAcls'] ?? true,
//      v: permissions['__v'] ?? 0,
    );
  }
}

class RoleType {
  final String id;
  final String name;

  RoleType({this.id, this.name});

  factory RoleType.fromMap(roleType) {
    return RoleType(id: roleType['_id'], name: roleType['name']);
  }
}

class EmployeeGroup {
  final String id;
  final String name;

//  String businessId;
//  List<Acl> acls = List<Acl>();

  EmployeeGroup({this.id, this.name});

  factory EmployeeGroup.fromMap(group) {
    return EmployeeGroup(id: group['_id'], name: group['name']);
  }
}
