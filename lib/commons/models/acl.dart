class Acl {
  final String microService;
  final bool create;
  final bool read;
  final bool update;
  final bool delete;

  dynamic aclData;

  Acl({this.microService, this.create, this.read, this.update, this.delete});

  factory Acl.fromMap(acl) {
    return Acl(
      microService: acl['microservice'],
      create: acl['create'] ?? false,
      read: acl['read'] ?? false,
      update: acl['update'] ?? false,
      delete: acl['delete'] ?? false,
    );
  }

  factory Acl.toMap(dynamic acl){
    return Acl.toMap(acl);
  }


}

