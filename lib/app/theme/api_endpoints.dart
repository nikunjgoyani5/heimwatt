class ApiEndpoints {
  static String updateLocation(String dealId) =>
      // 'https://europe-west3-heimwatt-app-ffe6c.cloudfunctions.net/hubspotProxy/crm/v3/objects/deals/$dealId';
      'https://api.staging.heim-watt.de/v1/deals/$dealId';

  static String getDealById(String dealId) =>
      // 'https://angebotstool-adapter-azureapp.redmoss-85e6a349.westus2.azurecontainerapps.io/api/deal/$dealId?show_labels=true&properties=objekt_adresszeile,objekt_postleitzahl,objekt_stadt,geplanter_heizungstyp';
      'https://api.staging.heim-watt.de/v1/deals/$dealId?include=photoGuide&showLabels=true';

  static String getContactDetailsBy(String contactId) =>
      // 'https://angebotstool-adapter-azureapp.redmoss-85e6a349.westus2.azurecontainerapps.io/api/Contact/$contactId?properties=firstname,lastname,email,salutation&show_labels=true';
      'https://api.staging.heim-watt.de/v1/contacts/$contactId';

  static String getContactBYToken =
      // 'https://angebotstool-adapter-azureapp.redmoss-85e6a349.westus2.azurecontainerapps.io/api/Contact/$contactId?properties=firstname,lastname,email,salutation&show_labels=true';
      'https://api.staging.heim-watt.de/v1/contacts/me';

  static String dealSearch =
      // 'https://angebotstool-adapter-azureapp.redmoss-85e6a349.westus2.azurecontainerapps.io/api/deal/search?show_labels=true';
      'https://api.staging.heim-watt.de/v1/deals?showLabels=true';

  static String uploadFile = 'https://europe-west3-heimwatt-app-ffe6c.cloudfunctions.net/hubspotProxy/files/v3/files';

  static String createNote =
      'https://europe-west3-heimwatt-app-ffe6c.cloudfunctions.net/hubspotProxy/crm/v3/objects/notes';

  static String linkFileToProperty(String dealId) =>
      'https://europe-west3-heimwatt-app-ffe6c.cloudfunctions.net/hubspotProxy/crm/v3/objects/deals/$dealId';

  static String uploadDocument(String dealId) => 'https://api.staging.heim-watt.de/v1/deals/$dealId/documents';
}
