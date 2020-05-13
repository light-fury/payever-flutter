class GroupAcl {
  final dynamic aclData;

  GroupAcl(this.aclData);

  toJson() {
    return aclData;
  }

  dynamic create;

//  GroupAcl({this.create});

  factory GroupAcl.toMap(acl){

//    final Map parsed = json.decode(acl);
//    print("parsed: $parsed");

    print("acl microservice: ${acl['microservice']}");

    return GroupAcl(
      acl
    );

  }




}

