class BusinessApps {
  final String id;
  final AllowedAcls allowedAcls;
  final String bootstrapScriptUrl;
  final String code;
  final DashboardInfo dashboardInfo;
  final bool isDefault;
  final bool installed;
  final String microUuid;
  final int order;
  final DateTime startAt;
  final bool started;
  final String tag;
  final String url;

  BusinessApps(
      {this.id,
      this.allowedAcls,
      this.bootstrapScriptUrl,
      this.code,
      this.dashboardInfo,
      this.isDefault,
      this.installed,
      this.microUuid,
      this.order,
      this.startAt,
      this.started,
      this.tag,
      this.url});

  factory BusinessApps.fromMap(dynamic app) {
    return BusinessApps(
      id: app['_id'],
      allowedAcls: AllowedAcls.fromMap(app['allowedAcls']),
      bootstrapScriptUrl: app['bootstrapScriptUrl'],
      code: app['code'],
      dashboardInfo: app['dashboardInfo'] == {}
          ? null
          : DashboardInfo.fromMap(app['dashboardInfo']),
      isDefault: app['default'],
      installed: app['installed'],
      microUuid: app['microUuid'],
      order: app['order'],
      startAt: app['startAt'] != null ? DateTime.parse(app['startAt']) : DateTime.now(),
      started: app['started'],
      tag: app['tag'],
      url: app['url'],
    );
  }
}

class AllowedAcls {
  bool create;
  bool read;
  bool update;
  bool delete;

  AllowedAcls({this.create, this.read, this.update, this.delete});

  factory AllowedAcls.fromMap(allowedAcls) {
    return AllowedAcls(
      create: allowedAcls['create'],
      read: allowedAcls['read'],
      update: allowedAcls['update'],
      delete: allowedAcls['delete'],
    );
  }

  factory AllowedAcls.fromInitialMap(allowedAcls) {
    return AllowedAcls(
      create: allowedAcls['create'],
      read: allowedAcls['read'],
      update: allowedAcls['update'],
      delete: allowedAcls['delete'],
    );
  }

}

class DashboardInfo {
  final String title;
  final String icon;

  DashboardInfo({this.title, this.icon});

  factory DashboardInfo.fromMap(dashboardInfo) {
    return DashboardInfo(
        title: dashboardInfo['title'], icon: dashboardInfo['icon']);
  }
}
