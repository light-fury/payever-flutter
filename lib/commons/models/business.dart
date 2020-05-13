import '../utils/utils.dart';

class Business {
  String _id;
  bool _active;
  String _createdAt;
  String _updatedAt;
  String _currency;
  String _email;
  String _logo;
  String _name;
  CompanyAddress _companyAddress;
  CompanyDetails _companyDetails;
  ContactDetails _contactDetails;

  Business.map(dynamic obj) {
    this._id = obj[GlobalUtils.DB_BUSINESS_ID];
    this._updatedAt = obj[GlobalUtils.DB_BUSINESS_UPDATED_AT];
    this._createdAt = obj[GlobalUtils.DB_BUSINESS_CREATE_AT];
    this._email = obj[GlobalUtils.DB_BUSINESS_EMAIL];
    this._logo = obj[GlobalUtils.DB_BUSINESS_LOGO];
    this._active = obj[GlobalUtils.DB_BUSINESS_ACTIVE];
    this._currency = obj[GlobalUtils.DB_BUSINESS_CURRENCY];
    this._name = obj[GlobalUtils.DB_BUSINESS_NAME];

    this._companyAddress =
        CompanyAddress.map(obj[GlobalUtils.DB_BUSINESS_COMPANY_ADDRESS]);
    this._companyDetails =
        CompanyDetails.map(obj[GlobalUtils.DB_BUSINESS_COMPANY_DETAILS]);
    this._contactDetails =
        ContactDetails.map(obj[GlobalUtils.DB_BUSINESS_CONTACT_DETAILS]);
  }

  String get id => _id;

  String get updatedAt => _updatedAt;

  String get createdAt => _createdAt;

  String get email => _email;

  String get logo => _logo;

  bool get active => _active;

  String get currency => _currency;

  String get name => _name;

  CompanyAddress get companyAddress => _companyAddress;

  CompanyDetails get companyDetails => _companyDetails;

  ContactDetails get contactDetails => _contactDetails;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map[GlobalUtils.DB_BUSINESS_ID] = _id;
    map[GlobalUtils.DB_BUSINESS_UPDATED_AT] = _updatedAt;
    map[GlobalUtils.DB_BUSINESS_CREATE_AT] = _createdAt;
    map[GlobalUtils.DB_BUSINESS_EMAIL] = _email;
    map[GlobalUtils.DB_BUSINESS_LOGO] = _logo;
    map[GlobalUtils.DB_BUSINESS_ACTIVE] = _active;
    map[GlobalUtils.DB_BUSINESS_CURRENCY] = _currency;
    map[GlobalUtils.DB_BUSINESS_NAME] = _name;

    return map;
  }
}

class CompanyAddress {
  String _city;
  String _country;
  String _createdAt;
  String _updatedAt;
  String _street;
  String _zipCode;
  String _id;

  CompanyAddress.map(dynamic obj) {
    this._city = obj[GlobalUtils.DB_BUSINESS_CA_CITY];
    this._country = obj[GlobalUtils.DB_BUSINESS_CA_COUNTRY];
    this._createdAt = obj[GlobalUtils.DB_BUSINESS_CA_CREATED_AT];
    this._updatedAt = obj[GlobalUtils.DB_BUSINESS_CA_UPDATED_AT];
    this._street = obj[GlobalUtils.DB_BUSINESS_CA_STREET];
    this._zipCode = obj[GlobalUtils.DB_BUSINESS_CA_ZIP_CODE];
    this._id = obj[GlobalUtils.DB_BUSINESS_CA_ID];
  }

  String get city => _city;

  String get country => _country;

  String get createdAt => _createdAt;

  String get updatedAt => _updatedAt;

  String get street => _street;

  String get zipCode => _zipCode;

  String get id => _id;
}

class CompanyDetails {
  String _createdAt;
  String _foundationYear;
  String _industry;
  String _product;
  String _updatedAt;
  String _id;
  SalesRange _salesRange;
  EmployeesRange _employeesRange;

  CompanyDetails.map(dynamic obj) {
    this._createdAt = obj[GlobalUtils.DB_BUSINESS_CMDT_CREATED_AT];
    this._foundationYear = obj[GlobalUtils.DB_BUSINESS_CMDT_FOUNDATION_YEAR];
    this._industry = obj[GlobalUtils.DB_BUSINESS_CMDT_INDUSTRY];
    this._product = obj[GlobalUtils.DB_BUSINESS_CMDT_PRODUCT];
    this._updatedAt = obj[GlobalUtils.DB_BUSINESS_CMDT_UPDATED_AT];
    this._id = obj[GlobalUtils.DB_BUSINESS_CMDT_ID];

    if (obj[GlobalUtils.DB_BUSINESS_CMDT_SALES_RANGE] != null) {
      this._salesRange =
          SalesRange.map(obj[GlobalUtils.DB_BUSINESS_CMDT_SALES_RANGE]);
    }
    if (obj[GlobalUtils.DB_BUSINESS_CMDT_EMPLOYEES_RANGE] != null) {
      this._employeesRange =
          EmployeesRange.map(obj[GlobalUtils.DB_BUSINESS_CMDT_EMPLOYEES_RANGE]);
    }
  }

  String get createdAt => _createdAt;

  String get foundationYear => _foundationYear;

  String get industry => _industry;

  String get product => _product;

  String get updatedAt => _updatedAt;

  String get id => _id;

  SalesRange get salesRange => _salesRange;

  EmployeesRange get employeesRange => _employeesRange;
}

class EmployeesRange {
  int _max;
  int _min;
  String _id;

  EmployeesRange.map(dynamic obj) {
    this._min = obj[GlobalUtils.DB_BUSINESS_CMDT_EMP_RANGE_MIN];
    this._max = obj[GlobalUtils.DB_BUSINESS_CMDT_EMP_RANGE_MAX];
    this._id = obj[GlobalUtils.DB_BUSINESS_CMDT_EMP_RANGE_ID];
  }

  int get max => _max;

  int get min => _min;

  String get id => _id;
}

class SalesRange {
  int _max;
  int _min;
  String _id;

  SalesRange.map(dynamic obj) {
    this._min = obj[GlobalUtils.DB_BUSINESS_CMDT_SALES_RANGE_MIN];
    this._max = obj[GlobalUtils.DB_BUSINESS_CMDT_SALES_RANGE_MAX];
    this._id = obj[GlobalUtils.DB_BUSINESS_CMDT_SALES_RANGE_ID];
  }

  int get max => _max;

  int get min => _min;

  String get id => _id;
}

class ContactDetails {
  String _createdAt;
  String _firstName;
  String _lastName;
  String _updatedAt;
  String _id;

  ContactDetails.map(dynamic obj) {
    this._createdAt = obj[GlobalUtils.DB_BUSINESS_CNDT_CREATED_AT];
    this._firstName = obj[GlobalUtils.DB_BUSINESS_CNDT_FIRST_NAME];
    this._lastName = obj[GlobalUtils.DB_BUSINESS_CNDT_LAST_NAME];
    this._updatedAt = obj[GlobalUtils.DB_BUSINESS_CNDT_UPDATED_AT];
    this._id = obj[GlobalUtils.DB_BUSINESS_CNDT_ID];
  }

  String get createdAt => _createdAt;

  String get fistName => _firstName;

  String get lastName => _lastName;

  String get updatedAt => _updatedAt;

  String get id => _id;
}
