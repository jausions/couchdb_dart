/// A library for interacting with CouchDB via server
/// applications or browser-based clients
///
/// It is making according to the CouchDB API.
/// > Requests are made using HTTP and requests are used
/// to request information from the database,
/// > store new data, and perform views and formatting of
/// the information stored within the documents.
///
/// More detailed information about API is [here](http://docs.couchdb.org/en/stable/index.html).
library couchdb;

export 'src/clients/couchdb_client.dart';
export 'src/databases.dart';
export 'src/design_documents.dart';
export 'src/documents.dart';
export 'src/exceptions/couchdb_exception.dart';
export 'src/interfaces/client_interface.dart';
export 'src/interfaces/databases_interface.dart';
export 'src/interfaces/design_documents_interface.dart';
export 'src/interfaces/documents_interface.dart';
export 'src/interfaces/local_documents_interface.dart';
export 'src/interfaces/server_interface.dart';
export 'src/local_documents.dart';
export 'src/responses/api_response.dart';
export 'src/responses/databases_response.dart';
export 'src/responses/design_documents_response.dart';
export 'src/responses/documents_response.dart';
export 'src/responses/local_documents_response.dart';
export 'src/responses/server_response.dart';
export 'src/server.dart';
export 'src/validator.dart';
