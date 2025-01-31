import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensures only verified doctors can add records",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let doctor = accounts.get("wallet_1")!;
    let patient = accounts.get("wallet_2")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("doctors-registry", "register-doctor", 
        [types.utf8("Dr. Smith"), types.ascii("MD123"), types.utf8("Cardiology")],
        doctor.address),
      Tx.contractCall("doctors-registry", "verify-doctor",
        [types.principal(doctor.address)],
        deployer.address),
      Tx.contractCall("medical-records", "add-record",
        [types.principal(patient.address), types.uint(1), types.buff(32), types.utf8("Test record")],
        doctor.address)
    ]);
    
    assertEquals(block.receipts.length, 3);
    assertEquals(block.height, 2);
    block.receipts[2].result.expectOk().expectBool(true);
  },
});

Clarinet.test({
  name: "Ensures access control works correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let patient = accounts.get("wallet_1")!;
    let doctor = accounts.get("wallet_2")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("medical-records", "grant-access",
        [types.principal(doctor.address), types.uint(100)],
        patient.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
  },
});
