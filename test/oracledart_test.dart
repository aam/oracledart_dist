library oracledart_test;

import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:oracledart/oracledart.dart';
import 'oracledart_sync_extension_test.dart' as sync_test;
import 'metadata_test.dart' as metadata_test;

void main() {
  useVMConfiguration();

  sync_test.main();
  metadata_test.main();

  var env = Platform.environment;
  var oracle_host = env['ORACLE_HOST'];
  if (oracle_host == null) {
    oracle_host = "w8-32-12core";
  }
  var oracle_port = env['ORACLE_PORT'];
  if (oracle_port == null)
    oracle_host = 1521;
  }

  test('Can connect', () {
    connect(
      "scott",
      "tiger",
      "(DESCRIPTION="
        "(ADDRESS=(PROTOCOL=TCP)(HOST=${oracle_host})(PORT=${oracle_port}))"
        "(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))")
    .then(
        expectAsync((oracleConnection) {
          expect(oracleConnection, isNotNull);
        }), onError: (error) {
          expect(true, isFalse, reason: "Failed to connect: $error");
        });
  });

  test('Should fail to connect', () {
    connect(
      "scott",
      "tiger",
      "(DESCRIPTION="
        "(ADDRESS=(PROTOCOL=TCP)(HOST=bigfakehost)(PORT=1521))"
        "(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))")
    .then(
        expectAsync(
            (oracleConnection) {
              expect(true, isFalse, reason: "Managed to connect to bigfakehost");
            },
            count: 0), 
        onError: expectAsync((error) {
          expect(error, startsWith("ORA-12545: Connect failed"));
        }));
  });

  test('Fail to getString from invalid position', () {
    connect(
      "scott",
      "tiger",
      "(DESCRIPTION="
        "(ADDRESS=(PROTOCOL=TCP)(HOST=${oracle_host})(PORT=${oracle_port}))"
        "(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))")
    .then(
        expectAsync((oracleConnection) {
          expect(oracleConnection, isNotNull);
          var resultset = oracleConnection.select("select job, avg(sal) from emp group by job");
          expect(resultset.next(), equals(true));
          expect(() => resultset.getString(3), throwsA(startsWith("ORA-32109: invalid column"))); }),
        onError: (error) {
          expect(true, isFalse, reason: "Failed to connect: $error");
        });
  });
}

