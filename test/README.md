# Testing CouchDB Dart Client

## Testing Environment

To be able to run the tests, you need to have a _.env.test_ file in the project
root folder. There is a _.env.test.sample_ file for you to copy and adjust to your
local environment.

## CouchDB Server

A live CouchDB server is required to run most of the tests. The connection parameters
are to be set in the aforementioned _.env.test_ file.

## Mock Server

The test suite includes a mock HTTP client / server that can process a limited
number of URLs.
