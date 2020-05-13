import 'utils.dart';

class Env {
  static String storage;
  static String users;
  static String business;
  static String auth;
  static String widgets;
  static String wallpapers;
  static String commerceOs;
  static String commerceOsBack;
  static String transactions;
  static String pos;
  static String checkout;
  static String checkoutPhp;
  static String media;
  static String builder;
  static String products;
  static String inventory;
  static String shops;
  static String wrapper;
  static String employees;
  static String appRegistry;

  Env.map(dynamic obj) {
    Env.users = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_USER];
    Env.business = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_BUSINESS];
    Env.auth = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_AUTH];
    Env.storage = obj[GlobalUtils.ENV_CUSTOM][GlobalUtils.ENV_STORAGE];
    Env.widgets = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_WIDGET];
    Env.transactions =
        obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_TRANSACTIONS];
    Env.wallpapers = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_WALLPAPER];
    Env.commerceOs = obj[GlobalUtils.ENV_FRONTEND][GlobalUtils.ENV_COMMERCE_OS];
    Env.commerceOsBack =
        obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_COMMERCE_OS];
    Env.pos = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_POS];
    Env.checkout = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_CHECKOUT];
    Env.checkoutPhp = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_CHECKOUT_PHP];
    Env.media = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_MEDIA];
    Env.products = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_PRODUCTS];
    Env.inventory = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_INVENTORY];
    Env.shops = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_SHOPS];
    Env.builder = obj[GlobalUtils.ENV_FRONTEND][GlobalUtils.ENV_BUILDER_CLIENT];
    Env.wrapper = obj[GlobalUtils.ENV_FRONTEND][GlobalUtils.ENV_WRAPPER];
    Env.employees = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_EMPLOYEES];
    Env.appRegistry = obj[GlobalUtils.ENV_BACKEND][GlobalUtils.ENV_APP_REGISTRY];
  }
}
